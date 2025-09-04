## Setup Instructions
1. Clone repository:
git clone https://github.com/username/food-detection-api
cd backend

2. Install dependencies:
pip install -r requirements.txt

3. Download pre-trained model:
python download_model.py

4. Run API:
python app/main.py

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