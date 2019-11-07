import 'package:flutter/material.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/theme/themes.dart';

class WorkerItem extends StatelessWidget {
  final Worker worker;
  final bool multiSelect;
  final bool isSelected;
  final Function(Worker worker, bool selected) onChanged;
  final Function(Worker worker) onRemoved;
  final WidgetPartBuilder<Worker> trailingBuilder;
  final Color activeColor;
  final Color backgroundColor;

  WorkerItem({
    @required this.worker,
    this.multiSelect = false,
    this.isSelected = false,
    this.onChanged,
    this.onRemoved,
    this.trailingBuilder,
    this.activeColor,
    this.backgroundColor,
  }) : assert(worker != null);

  @override
  Widget build(BuildContext context) {
    return ListTileItem<Worker>(
      backgroundColor: backgroundColor,
      activeColor: activeColor,
      isMultiSelect: multiSelect,
      isSelected: isSelected,
      onChange: onChanged,
      onRemove: onRemoved,
      source: worker,
      trailingBuilder: trailingBuilder,
      titleBuilder: (context, worker) {
        List<Widget> widgets = [];

        if (worker.mode != WorkerType.all) {
          widgets.add(
            AvatarImage(
              imagePath: worker.imagePath,
              placeHolderImagePath: YodelImages.profilePlaceHolder,
            ),
          );

          widgets.add(SizedBox(
            width: 8,
          ));
        }

        widgets.addAll([
          Text(
            worker.name,
            style: YodelTheme.bodyDefault,
            overflow: TextOverflow.ellipsis,
          )
        ]);

        return Row(children: widgets);
      },
    );
  }
}
