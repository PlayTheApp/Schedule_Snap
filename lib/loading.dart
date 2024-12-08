import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsLoadingController extends GetxController {
  static IsLoadingController get to => Get.find();

  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;
  set isLoading(bool value) => _isLoading.value = value;
  void setIsLoading(bool value) => _isLoading.value = value;

  Widget build(BuildContext context) {
    return Obx(//isLoading(obs)가 변경되면 다시 그림.
        () => Offstage(
              offstage: !IsLoadingController.to.isLoading, // isLoading이 false면 감춰~
              child: Stack(children: const <Widget>[
                //다시 stack
                Opacity(
                  //뿌옇게~
                  opacity: 0.5, //0.5만큼~
                  child: ModalBarrier(dismissible: false, color: Colors.black), //클릭 못하게~
                ),
                Center(
                  child: CircularProgressIndicator(), //무지성 돌돌이~
                ),
              ]),
            ));
  }
}
