import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mobile_nebula/components/SimplePage.dart';
import 'package:mobile_nebula/components/config/ConfigButtonItem.dart';
import 'package:mobile_nebula/components/config/ConfigItem.dart';
import 'package:mobile_nebula/components/config/ConfigSection.dart';
import 'package:mobile_nebula/components/config/ConfigTextItem.dart';
import 'package:mobile_nebula/models/Certificate.dart';
import 'package:mobile_nebula/services/share.dart';
import 'package:mobile_nebula/services/utils.dart';

import 'CertificateDetailsScreen.dart';

class CertificateResult {
  CertificateInfo certInfo;
  String key;

  CertificateResult({required this.certInfo, required this.key});
}

class AddCertificateScreen extends StatefulWidget {
  AddCertificateScreen({
    Key? key,
    this.onSave,
    this.onReplace,
    required this.pubKey,
    required this.privKey,
    required this.supportsQRScanning,
  }) : super(key: key);

  // onSave will pop a new CertificateDetailsScreen.
  // If onSave is null, onReplace must be set.
  ValueChanged<CertificateResult>? onSave;
  // onReplace will return the CertificateResult, assuming the previous screen is a CertificateDetailsScreen.
  // If onReplace is null, onSave must be set.
  ValueChanged<CertificateResult>? onReplace;

  String pubKey;
  String privKey;

  bool supportsQRScanning;

  @override
  _AddCertificateScreenState createState() => _AddCertificateScreenState();
}

class _AddCertificateScreenState extends State<AddCertificateScreen> {
  late String pubKey;
  bool showKey = false;

  String inputType = 'paste';

  final keyController = TextEditingController();
  final pasteController = TextEditingController();
  static const platform = MethodChannel('net.defined.mobileNebula/NebulaVpnService');

  @override
  void initState() {
    pubKey = widget.pubKey;
    keyController.text = widget.privKey;
    super.initState();
  }

  @override
  void dispose() {
    pasteController.dispose();
    keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    items.addAll(_buildShare());
    items.add(_buildKey());
    items.addAll(_buildLoadCert());

    return SimplePage(title: Text('Certificate'), child: Column(children: items));
  }

  List<Widget> _buildShare() {
    return [
      ConfigSection(
          label: 'Share your public key with a nebula CA so they can sign and return a certificate',
          children: [
            ConfigItem(
              labelWidth: 0,
              content: SelectableText(pubKey, style: TextStyle(fontFamily: 'RobotoMono', fontSize: 14)),
            ),
            Builder(
              builder: (BuildContext context) {
                return ConfigButtonItem(
                  content: Text('Share Public Key'),
                  onPressed: () async {
                    await Share.share(context,
                        title: 'Please sign and return a certificate',
                        text: pubKey,
                        filename: 'device.pub');
                  },
                );
            },
            ),
          ]),
      ConfigSection(
        children: [
          ConfigButtonItem(
              content: Center(child: Text('Load private key from file')),
              onPressed: () async {
                try {
                  final content = await Utils.pickFile(context);
                  if (content == null) {
                    return;
                  }

                  widget.privKey = content;
                  keyController.text = widget.privKey;
                } catch (err) {
                  return Utils.popError(context, 'Failed to load private key file', err.toString());
                }
              })
        ],
      )
    ];
  }

  List<Widget> _buildLoadCert() {
    Map<String, Widget> children = {
      'paste': Text('Copy/Paste'),
      'file': Text('File'),
    };

    // not all devices have a camera for QR codes
    if (widget.supportsQRScanning) {
      children['qr'] = Text('QR Code');
    }

    List<Widget> items = [
      Padding(
          padding: EdgeInsets.fromLTRB(10, 25, 10, 0),
          child: CupertinoSlidingSegmentedControl(
            groupValue: inputType,
            onValueChanged: (v) {
              if (v != null) {
                setState(() {
                  inputType = v;
                });
              }
            },
            children: children,
          ))
    ];

    if (inputType == 'paste') {
      items.addAll(_addPaste());
    } else if (inputType == 'file') {
      items.addAll(_addFile());
    } else if (inputType == 'qr') {
      items.addAll(_addQr());
    }

    return items;
  }

  Widget _buildKey() {
    if (!showKey) {
      return Padding(
          padding: EdgeInsets.only(top: 20, bottom: 10, left: 10, right: 10),
          child: SizedBox(
              width: double.infinity,
              child: PlatformElevatedButton(
                  child: Text('Show/Import Private Key'),
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  onPressed: () => Utils.confirmDelete(context, 'Show/Import Private Key?', () {
                        setState(() {
                          showKey = true;
                        });
                      }, deleteLabel: 'Yes'))));
    }

    return ConfigSection(
      label: 'Import a private key generated on another device',
      children: [
        ConfigTextItem(controller: keyController, style: TextStyle(fontFamily: 'RobotoMono', fontSize: 14)),
      ],
    );
  }

  List<Widget> _addPaste() {
    return [
      ConfigSection(
        children: [
          ConfigTextItem(
            placeholder: 'Certificate PEM Contents',
            controller: pasteController,
          ),
          ConfigButtonItem(
              content: Center(child: Text('Load Certificate')),
              onPressed: () {
                _addCertEntry(pasteController.text);
              }),
        ],
      )
    ];
  }

  List<Widget> _addFile() {
    return [
      ConfigSection(
        children: [
          ConfigButtonItem(
              content: Center(child: Text('Choose a file')),
              onPressed: () async {
                try {
                  final content = await Utils.pickFile(context);
                  if (content == null) {
                    return;
                  }

                  _addCertEntry(content);
                } catch (err) {
                  return Utils.popError(context, 'Failed to load certificate file', err.toString());
                }
              })
        ],
      )
    ];
  }

  List<Widget> _addQr() {
    return [
      ConfigSection(
        children: [
          ConfigButtonItem(
              content: Text('Scan a QR code'),
              onPressed: () async {
                try {
                  var result = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.QR);
                  if (result != "") {
                    _addCertEntry(result);
                  }
                } catch (err) {
                  return Utils.popError(context, 'Error scanning QR code', err.toString());
                }
              }),
        ],
      )
    ];
  }

  _addCertEntry(String rawCert) async {
    try {
      var rawCerts = await platform.invokeMethod("nebula.parseCerts", <String, String>{"certs": rawCert});

      List<dynamic> certs = jsonDecode(rawCerts);
      if (certs.length > 0) {
        var tryCertInfo = CertificateInfo.fromJson(certs.first);
        if (tryCertInfo.cert.details.isCa) {
          return Utils.popError(context, 'Error loading certificate content',
              'A certificate authority is not appropriate for a client certificate.');
        } else if (!tryCertInfo.validity!.valid) {
          return Utils.popError(context, 'Certificate was invalid', tryCertInfo.validity!.reason);
        }

        var certMatch = await platform
            .invokeMethod("nebula.verifyCertAndKey", <String, String>{"cert": rawCert, "key": keyController.text});
        if (!certMatch) {
          // The method above will throw if there is a mismatch, this is just here in case we introduce a bug in the future
          return Utils.popError(context, 'Error loading certificate content',
              'The provided certificates public key is not compatible with the private key.');
        }

        if (widget.onReplace != null) {
          // If we are replacing we just return the results now
          Navigator.pop(context);
          widget.onReplace!(CertificateResult(certInfo: tryCertInfo, key: keyController.text));
          return;
        } else if (widget.onSave != null) {
          // We have a cert, pop the details screen where they can hit save
          Utils.openPage(context, (context) {
            return CertificateDetailsScreen(
                certInfo: tryCertInfo,
                onSave: () {
                  Navigator.pop(context);
                  widget.onSave!(CertificateResult(certInfo: tryCertInfo, key: keyController.text));
                },
                supportsQRScanning: widget.supportsQRScanning,
            );
          });
        }
      }
    } on PlatformException catch (err) {
      return Utils.popError(context, 'Error loading certificate content', err.details ?? err.message);
    }
  }
}
