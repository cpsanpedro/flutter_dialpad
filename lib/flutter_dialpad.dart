library flutter_dialpad;

import 'dart:async';

import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dtmf/dtmf.dart';

class DialPad extends StatefulWidget {
  final ValueSetter<String>? makeCall;
  final ValueSetter<String>? keyPressed;
  final bool? hideDialButton;
  // buttonColor is the color of the button on the dial pad. defaults to Colors.gray
  final Color? buttonColor;
  final Color? buttonTextColor;
  final Color? dialButtonColor;
  final Color? dialButtonIconColor;
  final IconData? dialButtonIcon;
  final Color? backspaceButtonIconColor;
  final Color? dialOutputTextColor;
  // outputMask is the mask applied to the output text. Defaults to (000) 000-0000
  final String? outputMask;
  final bool? enableDtmf;
  final double? sizeFactorMultiplier;

  DialPad(
      {this.makeCall,
      this.keyPressed,
      this.hideDialButton,
      this.outputMask,
      this.buttonColor,
      this.buttonTextColor,
      this.dialButtonColor,
      this.dialButtonIconColor,
      this.dialButtonIcon,
      this.dialOutputTextColor,
      this.backspaceButtonIconColor,
      this.enableDtmf,
      this.sizeFactorMultiplier});

  @override
  _DialPadState createState() => _DialPadState();
}

class _DialPadState extends State<DialPad> {
  TextEditingController textEditingController = TextEditingController();
  var _value = "";
  var mainTitle = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "＃"];
  var subTitle = [
    "",
    "ABC",
    "DEF",
    "GHI",
    "JKL",
    "MNO",
    "PQRS",
    "TUV",
    "WXYZ",
    null,
    "+",
    null
  ];

  @override
  void initState() {
    super.initState();
  }

  _setText(String? value) async {
    if ((widget.enableDtmf == null || widget.enableDtmf!) && value != null)
      Dtmf.playTone(digits: value.trim(), samplingRate: 8000, durationMs: 160);

    if (widget.keyPressed != null) widget.keyPressed!(value!);

    setState(() {
      _value += value!;
      textEditingController!.text = _value;
    });
  }

  List<Widget> _getDialerButtons() {
    var rows = <Widget>[];
    var items = <Widget>[];

    for (var i = 0; i < mainTitle.length; i++) {
      if (i % 3 == 0 && i > 0) {
        rows.add(
            Row(mainAxisAlignment: MainAxisAlignment.center, children: items));
        rows.add(SizedBox(
          height: 12,
        ));
        items = <Widget>[];
      }

      items.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: DialButton(
          title: mainTitle[i],
          subtitle: subTitle[i],
          color: widget.buttonColor,
          textColor: widget.buttonTextColor,
          onTap: _setText,
          sizeFactorMultiplier: widget.sizeFactorMultiplier ?? 0.09852217,
        ),
      ));
    }
    //To Do: Fix this workaround for last row
    rows.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: items));

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var sizeFactor = screenSize.height * 0.09852217;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding:
              EdgeInsets.only(left: 32.0, bottom: 0.0, top: 0.0, right: 32.0),
          child: Container(
            height: 64.0,
            child: AutoSizeTextField(
              fullwidth: true,
              readOnly: true,
              style: TextStyle(
                  color: widget.dialOutputTextColor ?? Colors.black,
                  fontSize: sizeFactor / 2),
              textAlign: TextAlign.center,
              decoration: InputDecoration(border: InputBorder.none),
              controller: textEditingController,
            ),
          ),
        ),
        ..._getDialerButtons(),
        SizedBox(
          height: 15,
        ),
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: Container(),
            ),
            widget.hideDialButton != null && widget.hideDialButton!
                ? Container()
                : Center(
                    child: DialButton(
                      sizeFactorMultiplier:
                          widget.sizeFactorMultiplier ?? 0.09852217,
                      icon: widget.dialButtonIcon != null
                          ? widget.dialButtonIcon
                          : Icons.phone,
                      color: widget.dialButtonColor != null
                          ? widget.dialButtonColor!
                          : Colors.green,
                      iconColor: widget.dialButtonIconColor,
                      onTap: (value) {
                        widget.makeCall!(_value);
                      },
                    ),
                  ),
            Expanded(
                child: Material(
              // borderRadius: BorderRadius.circular(56.0),
              color: Colors.transparent,
              child: Container(
                width: sizeFactor,
                height: sizeFactor,
                // color: Colors.orange,
                child: Padding(
                  padding:
                      EdgeInsets.only(right: screenSize.height * 0.03685504),
                  child: IconButton(
                    splashColor: Colors.white60,
                    icon: Icon(
                      Icons.close,
                      size: sizeFactor / 2,
                      color: _value.length > 0
                          ? (widget.backspaceButtonIconColor != null
                              ? widget.backspaceButtonIconColor
                              : Colors.white24)
                          : Colors.white24,
                    ),
                    onPressed: _value.length == 0
                        ? null
                        : () {
                            if (_value.length > 0) {
                              setState(() {
                                _value = _value.substring(0, _value.length - 1);
                                textEditingController!.text = _value;
                              });
                            }
                          },
                  ),
                ),
              ),
            ))
          ],
        )
      ],
    );
  }
}

class DialButton extends StatefulWidget {
  final Key? key;
  final String? title;
  final String? subtitle;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final Color? iconColor;
  final ValueSetter<String?>? onTap;
  final bool? shouldAnimate;
  final double sizeFactorMultiplier;
  DialButton(
      {this.key,
      this.title,
      this.subtitle,
      this.color,
      this.textColor,
      this.icon,
      this.iconColor,
      this.shouldAnimate,
      this.onTap,
      this.sizeFactorMultiplier = 0.09852217});

  @override
  _DialButtonState createState() => _DialButtonState();
}

class _DialButtonState extends State<DialButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _colorTween;
  Timer? _timer;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _colorTween = ColorTween(
            begin: widget.color != null ? widget.color : Colors.white24,
            end: Colors.white)
        .animate(_animationController);

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
    if ((widget.shouldAnimate == null || widget.shouldAnimate!) &&
        _timer != null) _timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var sizeFactor = screenSize.height * widget.sizeFactorMultiplier;

    return GestureDetector(
      onTap: () {
        if (this.widget.onTap != null) this.widget.onTap!(widget.title);

        if (widget.shouldAnimate == null || widget.shouldAnimate!) {
          if (_animationController.status == AnimationStatus.completed) {
            _animationController.reverse();
          } else {
            _animationController.forward();
            _timer = Timer(const Duration(milliseconds: 200), () {
              setState(() {
                _animationController.reverse();
              });
            });
          }
        }
      },
      onLongPress: () {
        if (widget.subtitle == "+" && this.widget.onTap != null) {
          this.widget.onTap!(widget.subtitle);
        }
      },
      child: ClipOval(
          child: AnimatedBuilder(
              animation: _colorTween,
              builder: (context, child) => Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.0),
                        color: _colorTween.value),
                    height: sizeFactor,
                    width: sizeFactor,
                    child: Center(
                        child: widget.icon == null
                            ? widget.subtitle != null
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        widget.title!,
                                        style: TextStyle(
                                            fontSize: sizeFactor / 3,
                                            color: widget.textColor != null
                                                ? widget.textColor
                                                : Colors.black),
                                      ),
                                      Text(widget.subtitle!,
                                          style: TextStyle(
                                              fontSize: sizeFactor / 7,
                                              color: widget.textColor != null
                                                  ? widget.textColor
                                                  : Colors.black)),
                                      SizedBox(
                                        height: 8,
                                      ),
                                    ],
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(top: 0),
                                    child: Text(
                                      widget.title!,
                                      style: TextStyle(
                                          fontSize: sizeFactor / 3,
                                          color: widget.textColor != null
                                              ? widget.textColor
                                              : Colors.black),
                                    ))
                            : Icon(widget.icon,
                                size: sizeFactor / 2,
                                color: widget.iconColor != null
                                    ? widget.iconColor
                                    : Colors.white)),
                  ))),
    );
  }
}
