import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/theme.dart';

class PulseCard extends StatefulWidget {

  PulseCard({
    @required this.onCardClick,
    @required this.onCardLongPress,
    @required this.icon,
    @required this.text,
    this.bordercolor,
    this.radius,
    this.task_id,
  });

  final VoidCallback onCardClick;
  final VoidCallback onCardLongPress;
  final Icon icon;
  final double radius;
  final Color bordercolor;
  final String text;
  final String task_id;
  _PulseCardState createState() => _PulseCardState();
}

class _PulseCardState extends State<PulseCard>
    with SingleTickerProviderStateMixin {
  Animation<Color> colorAnimation;
  AnimationController controller;
  String name;
  bool pulsing;

  initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    final CurvedAnimation curve =
    CurvedAnimation(parent: controller, curve: Curves.easeIn);
    colorAnimation =
        ColorTween(begin: Colors.white, end: CompanyColors.accentRippled).animate(curve);

//    opacityAnimation = Tween(begin: 0, end: 255).animate(curve);

    if (DataManager.get().currentTimeCounter != null) print(DataManager.get().currentTimeCounter.task_id + ' ' + DataManager.get().currentTimeCounter.job_ids.toString());
    if (DataManager.get().currentTimeCounter == null) pulsing = false;
    else if (DataManager.get().currentTimeCounter.task_id == widget.task_id && DataManager.get().currentTimeCounter.job_ids.contains(DataManager.get().currentJobNumber)){
      pulsing = true;
      controller.forward();
    } else pulsing = false;

    colorAnimation.addListener(() {
      setState(() {});
    });

    colorAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        if (pulsing) controller.forward();
      }
      setState(() {
        if (DataManager.get().currentTimeCounter == null) pulsing = false;
        else if (DataManager.get().currentTimeCounter.task_id == widget.task_id && DataManager.get().currentTimeCounter.job_ids.contains(DataManager.get().currentJobNumber)){
          pulsing = true;
//          controller.forward();
        } else pulsing = false;
      });
    });
  }
  bool hasPhoto;
  bool photoSynced;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      padding: EdgeInsets.symmetric(vertical: 16.0),
    decoration: new BoxDecoration(
    color: colorAnimation.value,
    border: new Border.all(color: (widget.bordercolor != null) ? widget.bordercolor : Colors.black12, width: 2.0),
    borderRadius: (widget.radius != null) ? new BorderRadius.circular(widget.radius) : new BorderRadius.circular(50.0),
    ),
        child:
    new InkWell(
      onTap: () {
        widget.onCardClick();
        pulsing = !pulsing;
        if (pulsing) { controller.forward(); }
        else controller.reverse();
      },
      onLongPress: () {
        widget.onCardLongPress;
      },
//                    padding: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          new Container(
              width: 80.0,
              child: widget.icon
          ),
          Text(widget.text, style: Styles.logButton)
        ],
      ),
    )
    );
  }

  dispose() {
    controller.dispose();
    super.dispose();
  }
}