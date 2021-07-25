import 'package:cast/cast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cast_ui/src/util/extensions/cast/cast_device_extensions.dart';

class ChromecastDeviceListItem extends StatelessWidget {
  final CastDevice device;
  final VoidCallback onClick;

  const ChromecastDeviceListItem({
    required this.device,
    required this.onClick,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onClick,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              device.friendlyName,
              style: theme.textTheme.bodyText1,
            ),
            Text(
              device.deviceName,
              style: theme.textTheme.caption,
            ),
          ],
        ),
      ),
    );
  }
}
