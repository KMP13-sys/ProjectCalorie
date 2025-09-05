food_classifier.pt      # Main model ใช้ใน Backend
food_classifier.onnx    # สำหรับ React และ Flutter

---------------------แก้ไขให้ตามดาต้าเบสเครื่องตัวเองก่อนใช้ api--------------------------
database_config.json ???
.env ????
----------------------------------------------------------------------------------

------------------------------ใช้โมเดลใน Backend------------------------------------
//import libary
from ultralytics import YOLO
//โหลดโมเดล .pt
model = YOLO('models/food_classifier.pt')
-----------------------------------------------------------------------------------

-------------------------------ใช้โมเดลใน Flutter-----------------------------------
//เพิ่มใน .yaml
dependencies:
  onnxruntime: ^1.14.0
// โหลดโมเดล .onnx
final session = OrtSession.fromPath('assets/food_classifier.onnx');
----------------------------------------------------------------------------------

--------------------------------ใช้โมเดลใน React------------------------------------
//import libary
import * as ort from 'onnxruntime-web';
// โหลดโมเดล .onnx
const session = await ort.InferenceSession.create('/models/food_classifier.onnx');
-----------------------------------------------------------------------------------