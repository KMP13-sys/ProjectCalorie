# ------------------------------
# 1. Import libraries ที่จำเป็น
# ------------------------------
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms, models
from PIL import Image
import os
import json

# ---------------------------------------------------
# 2. สร้างคลาส Dataset สำหรับโหลดและจัดการข้อมูลภาพ
# ---------------------------------------------------
class FoodDataset(Dataset):
    def __init__(self, data_dir, transform=None):
        self.data_dir = data_dir
        self.transform = transform
        
        # อ่านชื่อโฟลเดอร์ย่อย (class แต่ละประเภท)
        self.classes = sorted(os.listdir(data_dir))
        
        # สร้าง mapping จากชื่อ class → หมายเลข index
        self.class_to_idx = {cls: idx for idx, cls in enumerate(self.classes)}
        
        self.samples = []  # เก็บ path ของรูปภาพทั้งหมดใน dataset
        
        # วนผ่านแต่ละคลาสเพื่อลงรายการไฟล์ภาพทั้งหมด
        for class_name in self.classes:
            class_dir = os.path.join(data_dir, class_name)
            if os.path.isdir(class_dir):
                for img_name in os.listdir(class_dir):
                    # รับเฉพาะไฟล์ .jpg, .jpeg, .png
                    if img_name.lower().endswith(('.png', '.jpg', '.jpeg')):
                        img_path = os.path.join(class_dir, img_name)
                        self.samples.append((img_path, self.class_to_idx[class_name]))
        
        print(f"Found {len(self.samples)} images in {len(self.classes)} classes")
    
    def __len__(self):
        # คืนค่าจำนวนตัวอย่างทั้งหมดใน dataset
        return len(self.samples)
    
    def __getitem__(self, idx):
        # โหลดรูปภาพตาม index
        img_path, label = self.samples[idx]
        image = Image.open(img_path).convert('RGB')
        
        # แปลงภาพด้วย transform ที่กำหนดไว้
        if self.transform:
            image = self.transform(image)
        
        return image, label


# ---------------------------------------------------
# 3. สร้างโมเดล EfficientNet (pre-trained) สำหรับจำแนกอาหาร
# ---------------------------------------------------
class EfficientNetClassifier(nn.Module):
    def __init__(self, num_classes):
        super().__init__()
        
        # โหลดโมเดล EfficientNet-B0 ที่ผ่านการ pre-train บน ImageNet แล้ว
        self.backbone = models.efficientnet_b0(pretrained=True)
        
        # ดึงจำนวน feature ที่ออกมาจากชั้นสุดท้าย
        in_features = self.backbone.classifier[1].in_features
        
        # แทนที่ classifier เดิม ด้วยของใหม่ที่มี output = จำนวนคลาสของเรา
        self.backbone.classifier = nn.Sequential(
            nn.Dropout(0.2),
            nn.Linear(in_features, num_classes)
        )
    
    def forward(self, x):
        # ฟังก์ชัน forward สำหรับ predict
        return self.backbone(x)


# ---------------------------------------------------
# 4. ฟังก์ชันหลักสำหรับ train / validate / test โมเดล
# ---------------------------------------------------
def train_model():
    # กำหนด path ของ dataset
    TRAIN_DIR = "../images/train"
    VAL_DIR = "../images/val"
    TEST_DIR = "../images/test"
    
    # ใช้ GPU ถ้ามี (CUDA)
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"Using device: {device}")
    
    # ------------------------------
    # 4.1 กำหนดการแปลงภาพ (Data Augmentation)
    # ------------------------------
    train_transform = transforms.Compose([
        transforms.Resize((224, 224)),           # ปรับขนาดภาพให้เท่ากัน
        transforms.RandomHorizontalFlip(),       # พลิกภาพแบบสุ่ม (ช่วยเพิ่มข้อมูล)
        transforms.ToTensor(),                   # แปลงภาพเป็น Tensor
        transforms.Normalize(                    # Normalize ตามค่า mean/std ของ ImageNet
            mean=[0.485, 0.456, 0.406],
            std=[0.229, 0.224, 0.225]
        )
    ])
    
    val_transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(
            mean=[0.485, 0.456, 0.406],
            std=[0.229, 0.224, 0.225]
        )
    ])
    
    # ------------------------------
    # 4.2 โหลดข้อมูล train / val / test
    # ------------------------------
    train_dataset = FoodDataset(TRAIN_DIR, train_transform)
    val_dataset = FoodDataset(VAL_DIR, val_transform)
    test_dataset = FoodDataset(TEST_DIR, val_transform)
    
    # ใช้ DataLoader เพื่อแบ่ง batch และ shuffle ข้อมูล
    train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True)
    val_loader = DataLoader(val_dataset, batch_size=32, shuffle=False)
    test_loader = DataLoader(test_dataset, batch_size=32, shuffle=False)
    
    # ------------------------------
    # 4.3 สร้างโมเดล EfficientNet
    # ------------------------------
    model = EfficientNetClassifier(num_classes=len(train_dataset.classes))
    model.to(device)
    
    # Loss function และ optimizer
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=1e-4)
    
    best_val_acc = 0.0  # เก็บค่าความแม่นยำสูงสุดของ validation
    
    # ------------------------------
    # 4.4 เริ่มการฝึกโมเดล
    # ------------------------------
    for epoch in range(10):  # จำนวนรอบ epoch
        model.train()  # ตั้งโหมด train
        for batch_idx, (images, labels) in enumerate(train_loader):
            images, labels = images.to(device), labels.to(device)
            
            optimizer.zero_grad()          # เคลียร์ gradient เก่า
            outputs = model(images)        # รัน forward pass
            loss = criterion(outputs, labels)  # คำนวณค่า loss
            loss.backward()                # คำนวณ gradient ย้อนกลับ
            optimizer.step()               # ปรับน้ำหนักโมเดล
            
            # แสดงผลทุก ๆ 5 batch
            if batch_idx % 5 == 0:
                print(f'Epoch {epoch+1}, Batch {batch_idx}, Loss: {loss.item():.4f}')
        
        # ------------------------------
        # 4.5 ตรวจสอบผลบน validation set
        # ------------------------------
        model.eval()
        correct = 0
        total = 0
        
        with torch.no_grad():  # ปิด gradient เพื่อลดการใช้ memory
            for images, labels in val_loader:
                images, labels = images.to(device), labels.to(device)
                outputs = model(images)
                _, predicted = torch.max(outputs.data, 1)
                total += labels.size(0)
                correct += (predicted == labels).sum().item()
        
        val_accuracy = 100 * correct / total
        print(f'Epoch {epoch+1}: Val Accuracy: {val_accuracy:.2f}%')
        
        # ถ้าค่าความแม่นยำดีขึ้น → บันทึกโมเดล
        if val_accuracy > best_val_acc:
            best_val_acc = val_accuracy
            torch.save(model.state_dict(), 'food_model.pth')
            print('New best model saved!')
    
    # ------------------------------
    # 4.6 ทดสอบโมเดลบน test set
    # ------------------------------
    model.load_state_dict(torch.load('food_model.pth'))
    model.eval()
    correct = 0
    total = 0
    
    with torch.no_grad():
        for images, labels in test_loader:
            images, labels = images.to(device), labels.to(device)
            outputs = model(images)
            _, predicted = torch.max(outputs.data, 1)
            total += labels.size(0)
            correct += (predicted == labels).sum().item()
    
    test_accuracy = 100 * correct / total
    
    print("\nFinal Results:")
    print(f"Best Val Accuracy: {best_val_acc:.2f}%")
    print(f"Test Accuracy: {test_accuracy:.2f}%")
    
    # ------------------------------
    # 4.7 แปลงโมเดลให้อยู่ในหลายรูปแบบ (mobile, web)
    # ------------------------------
    print("\nConverting model to different formats...")
    dummy_input = torch.randn(1, 3, 224, 224).to(device)  # ใช้ input จำลอง
    
    # 1️⃣ TorchScript → ใช้กับ mobile app (Android/iOS)
    try:
        scripted_model = torch.jit.trace(model, dummy_input)
        scripted_model.save('food_model_mobile.pt')
        print("✓ Mobile model saved: food_model_mobile.pt")
    except Exception as e:
        print(f"✗ Mobile conversion failed: {e}")
    
    # 2️⃣ ONNX → ใช้กับ web (เช่นใน JavaScript)
    try:
        torch.onnx.export(
            model,
            dummy_input,
            'food_model_web.onnx',
            export_params=True,
            opset_version=11,
            do_constant_folding=True,
            input_names=['input'],
            output_names=['output']
        )
        print("✓ Web model saved: food_model_web.onnx")
    except Exception as e:
        print(f"✗ ONNX conversion failed: {e}")
    
    # 3️⃣ สร้างไฟล์ mapping class → index
    class_mapping = {
        "class_to_idx": train_dataset.class_to_idx,
        "idx_to_class": {str(v): k for k, v in train_dataset.class_to_idx.items()},
        "num_classes": len(train_dataset.classes)
    }
    
    with open('class_mapping.json', 'w') as f:
        json.dump(class_mapping, f, indent=2)
    
    print("✓ Class mapping saved: class_mapping.json")
    print("\nFiles ready for frontend:")
    print("- food_model.pth (Backend)")
    print("- food_model_mobile.pt (iOS/Android)")
    print("- food_model_web.onnx (Web/JS)")
    print("- class_mapping.json (All platforms)")

# ------------------------------
# 5. เรียกฟังก์ชัน train_model เมื่อรันไฟล์นี้โดยตรง
# ------------------------------
if __name__ == "__main__":
    train_model()
