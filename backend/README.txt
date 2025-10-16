best_food_model.pth      # Main model สำหรับ Backend
food_model_web.onnx      # สำหรับ web เป็น JavaScript/ONNX.js
food_model_mobile.pt     # สำหรับ mobile andriod/ios เป็น TorchScript format
class_mapping.json       # เป็นข้อมูล class mapping คือ โมเดลจำเป็น index 0, 1, 2 ต้องมีไฟล์นี้เพื่อกำหนดให้รู้ตามคลาสที่ใช้เป็น id 1, 2, 3 ในดาต้าเบสได้

# Setup Environment Variables
1. Copy .env.example to .env: `cp src/config/.env.example src/config/.env`
2. Update the values in .env according to your database configuration
3. Never commit the .env file to version control

***ไกด์ไลน์ในการเรียกใช้โมเดลในแต่ละแพลตฟอร์ม***

------------------------------ใช้โมเดลใน Backend------------------------------------
### Import Libraries
```python
import torch
import torch.nn as nn
from torchvision import transforms, models
import json
```

### Load Model เรียกใช้
```python
# Load model
model = EfficientNetClassifier(num_classes=3)
model.load_state_dict(torch.load('best_food_model.pth'))
model.eval()

# Load class mapping
with open('class_mapping.json', 'r') as f:
    class_mapping = json.load(f)
```

### Usage ใช้งาน
```python
# Predict
outputs = model(preprocessed_image)
predicted_idx = torch.argmax(outputs).item()
predicted_class = class_mapping['idx_to_class'][str(predicted_idx)]
confidence = torch.softmax(outputs, dim=1)[0][predicted_idx].item()
```
-----------------------------------------------------------------------------------

-------------------------------ใช้โมเดลใน Flutter-----------------------------------
### เพิ่ม Dependencies (ในไฟล์ pubspec.yaml)
```yaml
dependencies:
  onnxruntime: ^1.14.0
  image: ^4.0.0
```

### Load Model เรียกใช้
```dart
// Load ONNX model
final session = OrtSession.fromPath('assets/food_model_web.onnx');

// Load class mapping
String mappingJson = await rootBundle.loadString('assets/class_mapping.json');
Map classMapping = json.decode(mappingJson);
```

### Usage ใช้งาน
```dart
// Run inference
final outputs = session.run(OrtValueTensor.createTensorWithData(inputData));
final prediction = outputs[0].value as List<List>;
int predictedIdx = prediction[0].indexOf(prediction[0].reduce(math.max));
String predictedClass = classMapping['idx_to_class'][predictedIdx.toString()];
```
----------------------------------------------------------------------------------

--------------------------------ใช้โมเดลใน React------------------------------------
### Import Libraries
```javascript
import * as ort from 'onnxruntime-web';
```

### Load Model เรียกใช้
```javascript
// Load ONNX model
const session = await ort.InferenceSession.create('/models/food_model_web.onnx');

// Load class mapping
const response = await fetch('/models/class_mapping.json');
const classMapping = await response.json();
```

### Usage ใช้งาน
```javascript
// Run inference
const results = await session.run({ input: preprocessedImage });
const predictions = results.output.data;
const predictedIdx = predictions.indexOf(Math.max(...predictions));
const predictedClass = classMapping.idx_to_class[predictedIdx.toString()];
const confidence = predictions[predictedIdx];
```
-----------------------------------------------------------------------------------

--------------------- ## Image Preprocessing --------------------------------------
All platforms need to preprocess images to 224x224 pixels with normalization:
- Mean: [0.485, 0.456, 0.406]
- Std: [0.229, 0.224, 0.225]
-----------------------------------------------------------------------------------