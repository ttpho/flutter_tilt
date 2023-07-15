import 'package:flutter/material.dart';

import 'package:flutter_tilt/src/utils.dart';
import 'package:flutter_tilt/src/type/tilt_type.dart';
import 'package:flutter_tilt/src/type/tilt_light_type.dart';
import 'package:flutter_tilt/src/type/tilt_shadow_type.dart';

import 'package:flutter_tilt/src/tilt_light.dart';
import 'package:flutter_tilt/src/tilt_shadow.dart';

import 'package:flutter_tilt/src/state/tilt_state.dart';

class TiltContainer extends StatefulWidget {
  const TiltContainer({
    Key? key,
    required this.child,
    this.borderRadius,
    required this.clipBehavior,
    required this.tiltConfig,
    required this.lightConfig,
    required this.shadowConfig,
  }) : super(key: key);

  final Widget child;

  /// BorderRadius
  final BorderRadiusGeometry? borderRadius;

  /// Clip
  final Clip clipBehavior;

  /// 倾斜配置
  final TiltConfig tiltConfig;

  /// 光源配置
  final LightConfig lightConfig;

  /// 阴影配置
  final ShadowConfig shadowConfig;

  @override
  State<TiltContainer> createState() => _TiltContainerState();
}

class _TiltContainerState extends State<TiltContainer> {
  late final Widget _child = widget.child;
  late final BorderRadiusGeometry? _borderRadius = widget.borderRadius;
  late final Clip _clipBehavior = widget.clipBehavior;
  late final TiltConfig _tiltConfig = widget.tiltConfig;
  late final LightConfig _lightConfig = widget.lightConfig;
  late final ShadowConfig _shadowConfig = widget.shadowConfig;

  /// 初始坐标区域进度
  late final Offset _initAreaProgress = _tiltConfig.initTilt ?? Offset.zero;

  late TiltState tiltState;

  /// 是否初始化
  late bool isInit;
  late double width, height;

  /// 当前坐标区域进度
  late Offset areaProgress = _initAreaProgress;

  /// 是否正在移动
  late bool isMove;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    tiltState = TiltState.of(context)!;

    isInit = tiltState.isInit;
    width = tiltState.width;
    height = tiltState.height;
    areaProgress = tiltState.areaProgress;
    isMove = tiltState.isMove;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: isMove ? 100 : 300),
      tween: Tween<Offset>(end: isMove ? areaProgress : _initAreaProgress),
      builder: (BuildContext context, Offset value, Widget? child) {
        return IgnorePointer(
          ignoring: false,
          child: Transform(
            alignment: AlignmentDirectional.center,
            transform: isInit && !_tiltConfig.disable
                ? tiltTransform(
                    width,
                    height,
                    value,
                    _tiltConfig.angle,
                    _tiltConfig.isReverse,
                  )
                : Matrix4.identity(),
            child: TiltShadow(
              width: width,
              height: height,
              areaProgress: value,
              borderRadius: _borderRadius,
              clipBehavior: _clipBehavior,
              lightConfig: _lightConfig,
              shadowConfig: _shadowConfig,
              child: Stack(
                alignment: AlignmentDirectional.center,

                /// 避免暴露其他组件，[Clip.none] 时，默认赋值 [Clip.hardEdge]
                clipBehavior:
                    _clipBehavior == Clip.none ? Clip.hardEdge : _clipBehavior,
                children: [
                  /// Body
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: _borderRadius,
                    ),
                    clipBehavior: _clipBehavior,
                    child: child,
                  ),

                  TiltLight(
                    width: width,
                    height: height,
                    areaProgress: value,
                    borderRadius: _borderRadius,
                    clipBehavior: _clipBehavior,
                    lightConfig: _lightConfig,
                  ),

                  /// Resize
                  Positioned.fill(
                    child: LayoutBuilder(builder: (context, constraints) {
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) => tiltState.onResize(constraints.biggest),
                      );
                      return const SizedBox();
                    }),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: _child,
    );
  }
}
