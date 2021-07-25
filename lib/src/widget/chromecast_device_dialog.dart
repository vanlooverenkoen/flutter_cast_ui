import 'package:cast_ui/src/viewmodel/chromecast_device_list_view_model.dart';
import 'package:cast_ui/src/widget/chromecast_device_list_item.dart';
import 'package:cast_ui/src/widget/chromecast_player.dart';
import 'package:cast_ui/src/widget/provider/provider_widget.dart';
import 'package:cast_ui/src/util/extensions/context_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChromecastDeviceDialog extends StatefulWidget {
  final String? title;
  final String? emptyText;
  final String? retryButtonText;

  const ChromecastDeviceDialog({
    this.title,
    this.emptyText,
    this.retryButtonText,
    Key? key,
  }) : super(key: key);

  @override
  _ChromecastDeviceDialogState createState() => _ChromecastDeviceDialogState();
}

class _ChromecastDeviceDialogState extends State<ChromecastDeviceDialog> implements ChromecastDeviceListNavigator {
  @override
  Widget build(BuildContext context) {
    return ProviderWidget<ChromecastDeviceListViewModel>(
      create: () => ChromecastDeviceListViewModel()..init(this),
      consumer: (context, viewModel, child) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              context.isAndroidTheme ? 4 : 16,
            ),
          ),
          child: Builder(
            builder: (context) {
              if (viewModel.isConnected) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
                      child: const ChromecastPlayer(),
                    ),
                  ],
                );
              }
              return Padding(
                padding: EdgeInsets.only(
                  top: 16,
                  bottom: viewModel.hasData ? 0 : 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(widget.title ?? 'Select a device'),
                    ),
                    const SizedBox(height: 12),
                    if (viewModel.isLoading) ...[
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                      const SizedBox(height: 16),
                    ] else if (viewModel.hasError) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          widget.emptyText ?? 'Something went wrong. Try again.',
                        ),
                      ),
                      Center(
                        child: IconButton(
                          onPressed: viewModel.onRetryClicked,
                          icon: const Icon(Icons.refresh),
                        ),
                      ),
                    ] else if (viewModel.hasNoData) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          widget.emptyText ?? 'No devices found',
                        ),
                      ),
                      Center(
                        child: IconButton(
                          onPressed: viewModel.onRetryClicked,
                          icon: const Icon(Icons.refresh),
                        ),
                      ),
                    ] else if (viewModel.hasData) ...[
                      Container(
                        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: viewModel.data.length,
                          itemBuilder: (context, index) {
                            final device = viewModel.data[index];
                            return ChromecastDeviceListItem(
                              device: device,
                              onClick: () => viewModel.onDeviceClicked(device),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void goBack() => Navigator.of(context).pop();
}
