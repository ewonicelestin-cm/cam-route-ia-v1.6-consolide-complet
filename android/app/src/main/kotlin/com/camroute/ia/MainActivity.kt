package com.camroute.ia

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.CellInfo
import android.telephony.CellInfoCdma
import android.telephony.CellInfoGsm
import android.telephony.CellInfoLte
import android.telephony.CellInfoWcdma
import android.telephony.TelephonyManager
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL_NAME = "camroute/network"
        private const val METHOD_SNAPSHOT = "getNetworkSnapshot"

        private const val ERROR_PERMISSION = "permission"
        private const val ERROR_NO_TELEPHONY = "no_telephony"
        private const val ERROR_SECURITY = "security"
        private const val ERROR_UNAVAILABLE = "unavailable"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_SNAPSHOT -> {
                    result.success(readNetworkInfo())
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun readNetworkInfo(): Map<String, Any?> {
        if (!hasLocationPermission()) {
            return errorResult(ERROR_PERMISSION)
        }

        val telephonyManager =
            getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
                ?: return errorResult(ERROR_NO_TELEPHONY)

        return try {
            val operator = telephonyManager.networkOperatorName
                .orEmpty()
                .ifBlank { "Opérateur inconnu" }

            val cells: List<CellInfo> =
                telephonyManager.allCellInfo ?: emptyList()

            val registeredCell = cells.firstOrNull { it.isRegistered }

            if (registeredCell == null) {
                snapshot(
                    operator = operator,
                    technology = "Inconnue",
                    signalDbm = null,
                    qualityDb = null
                )
            } else {
                readRegisteredCell(operator, registeredCell)
            }
        } catch (e: SecurityException) {
            errorResult(ERROR_SECURITY)
        } catch (e: Exception) {
            // Le service réseau peut être temporairement indisponible.
            errorResult(ERROR_UNAVAILABLE)
        }
    }

    private fun hasLocationPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun readRegisteredCell(
        operator: String,
        cell: CellInfo
    ): Map<String, Any?> {
        var technology = "Inconnue"
        var signalDbm: Int? = null
        var qualityDb: Int? = null

        when (cell) {
            is CellInfoGsm -> {
                technology = "2G"
                signalDbm = validMeasurement(
                    cell.cellSignalStrength.dbm
                )
            }

            is CellInfoWcdma -> {
                technology = "3G"
                signalDbm = validMeasurement(
                    cell.cellSignalStrength.dbm
                )
            }

            is CellInfoLte -> {
                technology = "4G/LTE"

                signalDbm = validMeasurement(
                    cell.cellSignalStrength.dbm
                )

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    qualityDb = validMeasurement(
                        cell.cellSignalStrength.rsrq
                    )
                }
            }

            is CellInfoCdma -> {
                technology = "CDMA"
                signalDbm = validMeasurement(
                    cell.cellSignalStrength.dbm
                )
            }

            else -> {
                // Les API NR et TD-SCDMA existent à partir d'Android 10.
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    when {
                        isNrCell(cell) -> {
                            technology = "5G NR"
                            signalDbm = readNrSignalDbm(cell)
                        }

                        isTdscdmaCell(cell) -> {
                            technology = "3G/TD-SCDMA"
                            signalDbm = readTdscdmaSignalDbm(cell)
                        }
                    }
                }
            }
        }

        return snapshot(
            operator = operator,
            technology = technology,
            signalDbm = signalDbm,
            qualityDb = qualityDb
        )
    }

    private fun isNrCell(cell: CellInfo): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            cell is android.telephony.CellInfoNr
        } else {
            false
        }
    }

    private fun readNrSignalDbm(cell: CellInfo): Int? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            return null
        }

        val nrCell = cell as? android.telephony.CellInfoNr ?: return null

        return validMeasurement(
            nrCell.cellSignalStrength.dbm
        )
    }

    private fun isTdscdmaCell(cell: CellInfo): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            return false
        }

        return cell is android.telephony.CellInfoTdscdma
    }

    private fun readTdscdmaSignalDbm(cell: CellInfo): Int? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            return null
        }

        val tdscdmaCell =
            cell as? android.telephony.CellInfoTdscdma ?: return null

        return validMeasurement(
            tdscdmaCell.cellSignalStrength.dbm
        )
    }

    private fun validMeasurement(value: Int): Int? {
        return if (
            value == Int.MAX_VALUE ||
            value == Int.MIN_VALUE
        ) {
            null
        } else {
            value
        }
    }

    private fun snapshot(
        operator: String,
        technology: String,
        signalDbm: Int?,
        qualityDb: Int?
    ): Map<String, Any?> {
        return mapOf(
            "operator" to operator,
            "technology" to technology,
            "signalDbm" to signalDbm,
            "qualityDb" to qualityDb
        )
    }

    private fun errorResult(
        error: String
    ): Map<String, Any?> {
        return mapOf(
            "error" to error,
            "operator" to "",
            "technology" to "Inconnue",
            "signalDbm" to null,
            "qualityDb" to null
        )
    }
}