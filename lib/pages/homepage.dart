import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:preference_list/preference_list.dart';
import 'package:tray_manager/tray_manager.dart';

const _kIconTypeDefault = 'default';
const _kIconTypeOriginal = 'original';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TrayListener {
  String _iconType = _kIconTypeOriginal;

  Timer? _timer;

  @override
  void initState() {
    TrayManager.instance.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    TrayManager.instance.removeListener(this);
    super.dispose();
  }

  void _handleSetIcon(String iconType) async {
    _iconType = iconType;
    String iconPath =
        Platform.isWindows ? 'images/tray_icon.ico' : 'images/tray_icon.png';

    if (_iconType == 'original') {
      iconPath = Platform.isWindows
          ? 'images/tray_icon_original.ico'
          : 'images/tray_icon_original.png';
    }

    await TrayManager.instance.setIcon(iconPath);
  }

  void _startIconFlashing() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      _handleSetIcon(_iconType == _kIconTypeOriginal
          ? _kIconTypeDefault
          : _kIconTypeOriginal);
    });
    setState(() {});
  }

  void _stopIconFlashing() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
  }

  Widget _buildBody(BuildContext context) {
    return PreferenceList(
      children: <Widget>[
        PreferenceListSection(
          children: [
            PreferenceListItem(
              title: const Text('destroy'),
              onTap: () {
                TrayManager.instance.destroy();
              },
            ),
            PreferenceListItem(
              title: const Text('setIcon'),
              accessoryView: Row(
                children: [
                  Builder(builder: (_) {
                    bool isFlashing = (_timer != null && _timer!.isActive);
                    return CupertinoButton(
                      child: isFlashing
                          ? const Text('stop flash')
                          : const Text('start flash'),
                      onPressed:
                          isFlashing ? _stopIconFlashing : _startIconFlashing,
                    );
                  }),
                  CupertinoButton(
                    child: const Text('Default'),
                    onPressed: () => _handleSetIcon(_kIconTypeDefault),
                  ),
                  CupertinoButton(
                    child: const Text('Original'),
                    onPressed: () => _handleSetIcon(_kIconTypeOriginal),
                  ),
                ],
              ),
              onTap: () => _handleSetIcon(_kIconTypeDefault),
            ),
            // PreferenceListItem(
            //   title: Text('setToolTip'),
            //   onTap: () async {
            //     await TrayManager.instance.setToolTip('tray_manager');
            //   },
            // ),
            PreferenceListItem(
              title: const Text('setContextMenu'),
              onTap: () async {
                List<MenuItem> items = [
                  MenuItem(title: 'Undo'),
                  MenuItem(title: 'Redo'),
                  MenuItem.separator,
                  MenuItem(title: 'Cut'),
                  MenuItem(title: 'Copy'),
                  MenuItem(
                    title: 'Copy As',
                    items: [
                      MenuItem(title: 'Copy Remote File Url'),
                      MenuItem(title: 'Copy Remote File Url From...'),
                    ],
                  ),
                  MenuItem(title: 'Paste'),
                  MenuItem.separator,
                  MenuItem(title: 'Find', isEnabled: false),
                  MenuItem(title: 'Replace'),
                ];
                await TrayManager.instance.setContextMenu(items);
              },
            ),
            PreferenceListItem(
              title: const Text('popUpContextMenu'),
              onTap: () async {
                await TrayManager.instance.popUpContextMenu();
              },
            ),
            PreferenceListItem(
              title: const Text('getBounds'),
              onTap: () async {
                Rect bounds = await TrayManager.instance.getBounds();
                Size size = bounds.size;
                Offset origin = bounds.topLeft;
                BotToast.showText(
                  text: '${size.toString()}\n${origin.toString()}',
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: _buildBody(context),
    );
  }

  @override
  void onTrayIconMouseDown() {
    TrayManager.instance.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseDown() {
    TrayManager.instance.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseUp() {
    debugPrint(TrayManager.instance.getBounds().toString());
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    debugPrint(menuItem.toJson().toString());
    BotToast.showText(
      text: "Pulsado el item con Id: ${menuItem.id}, "
          "y el texto ${menuItem.title}",
    );
  }
}
