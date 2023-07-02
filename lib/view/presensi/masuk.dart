import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hris_apps/style/color.dart';
import 'package:hris_apps/view/presensi/ambil.dart';
import 'package:hris_apps/view/presensi/presensi.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key, required this.cameras}) : super(key: key);

  final List<CameraDescription>? cameras;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  bool _isRearCameraSelected = true;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initCamera(widget.cameras![0]);
  }

  Future<bool> _onWillPop() async {
    return (await QuickAlert.show(
          context: context,
          type: QuickAlertType.warning,
          confirmBtnColor: AppColor.primary,
          title: 'Kembali ?',
          text: 'Apakah Anda Ingin Membatalkan Presensi ?',
          onConfirmBtnTap: () {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context).pop(true);
          },
        )) ??
        false;
  }

  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.off);
      XFile picture = await _cameraController.takePicture();
      print(picture.path);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => PreviewPage(
                    picture: picture,
                  )));
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.medium);
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = 4 / 3;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(top: 100),
          child: Stack(children: [
            (_cameraController.value.isInitialized)
                ? CameraPreview(_cameraController)
                : Container(
                    color: Color.fromARGB(255, 255, 255, 255),
                    child: const Center(child: CircularProgressIndicator())),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.20,
                  decoration: const BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                      color: Color.fromARGB(255, 251, 251, 251)),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 30,
                          icon: Icon(
                              _isRearCameraSelected
                                  ? CupertinoIcons.switch_camera
                                  : CupertinoIcons.switch_camera_solid,
                              color: AppColor.primary),
                          onPressed: () {
                            setState(() =>
                                _isRearCameraSelected = !_isRearCameraSelected);
                            initCamera(
                                widget.cameras![_isRearCameraSelected ? 0 : 1]);
                          },
                        )),
                        Expanded(
                            child: IconButton(
                          onPressed: takePicture,
                          iconSize: 50,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.camera,
                              color: Color(0xFF5F72E4)),
                        )),
                        const Spacer(),
                      ]),
                )),
          ]),
        ),
      )),
    );
  }
}
