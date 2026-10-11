package com.camroute.ia

import android.os.Build
import android.telephony.CellInfo
import android.telephony.CellInfoGsm
import android.telephony.CellInfoLte
import android.telephony.CellInfoNr
import android.telephony.CellInfoWcdma
import android.telephony.CellSignalStrengthLte
import android.telephony.CellSignalStrengthNr
import android.telephony.TelephonyManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private companion object {
        const val CHANNEL_NAME = "camroute/network"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME
        ).setMethodCallHandler { call, result ->

            when (call.method) {
                "getNetworkSnapshot" -> {
                    result.success(readNetworkSnapshot())
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun readNetworkSnapshot(): Map<String, Any?> {

        val manager =
            getSystemService(TELEPHONY_SERVICE) as TelephonyManager

        var technology = "Non identifiée"
        var signalDbm: Int? = null
        var qualityDb: Int? = null

        try {

            val cells: List<CellInfo> =
                manager.allCellInfo ?: emptyList()

            val registeredCell =
                cells.firstOrNull { it.isRegistered }
                    ?: cells.firstOrNull()

            when (registeredCell) {

                is CellInfoNr -> {

                    technology = "5G"

                    val signal =
                        registeredCell.cellSignalStrength as? CellSignalStrengthNr

                    if (signal != null) {
                        signalDbm = signal.dbm

                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            qualityDb = signal.rsrq
                        }
                    }
                }

                is CellInfoLte -> {

                    technology = "4G/LTE"

                    val signal =
                        registeredCell.cellSignalStrength as? CellSignalStrengthLte

                    if (signal != null) {
                        signalDbm = signal.dbm
                        qualityDb = signal.rsrq
                    }
                }

                is CellInfoWcdma -> {

                    technology = "3G/WCDMA"

                    signalDbm =
                        registeredCell.cellSignalStrength.dbm
                }

                is CellInfoGsm -> {

                    technology = "2G/GSM"

                    signalDbm =
                        registeredCell.cellSignalStrength.dbm
                }
            }

        } catch (_: SecurityException) {

            // Certaines informations réseau nécessitent
            // des permissions Android ou peuvent être masquées
            // par le constructeur.

        } catch (_: Exception) {

            // Protection contre les erreurs spécifiques
            // à certains appareils Android.
        }

        val operator = try {

            manager.networkOperatorName
                ?.takeIf { it.isNotBlank() }
                ?: "Opérateur non identifié"

        } catch (_: SecurityException) {

            "Opérateur non identifié"
        }

        return mapOf(
            "operator" to operator,
            "technology" to technology,
            "signalDbm" to signalDbm,
            "qualityDb" to qualityDb
        )
    }
}