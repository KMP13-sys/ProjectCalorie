best_food_model.pth      # Main model สำหรับ Backend
food_model_web.onnx      # สำหรับ web เป็น JavaScript/ONNX.js (ไม่ได้ใช้)
food_model_mobile.pt     # สำหรับ mobile andriod/ios เป็น TorchScript format (ไม่ได้ใช้)
class_mapping.json       # เป็นข้อมูล class mapping คือ โมเดลจำเป็น index 0, 1, 2 ต้องมีไฟล์นี้เพื่อกำหนดให้รู้ตามคลาสที่ใช้เป็น id 1, 2, 3 ในดาต้าเบสได้