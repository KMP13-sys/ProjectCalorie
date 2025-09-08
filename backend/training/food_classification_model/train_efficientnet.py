import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms, models
from PIL import Image
import os

class FoodDataset(Dataset):
    def __init__(self, data_dir, transform=None):
        self.data_dir = data_dir
        self.transform = transform
        self.classes = sorted(os.listdir(data_dir))
        self.class_to_idx = {cls: idx for idx, cls in enumerate(self.classes)}
        
        self.samples = []
        for class_name in self.classes:
            class_dir = os.path.join(data_dir, class_name)
            if os.path.isdir(class_dir):
                for img_name in os.listdir(class_dir):
                    if img_name.lower().endswith(('.png', '.jpg', '.jpeg')):
                        img_path = os.path.join(class_dir, img_name)
                        self.samples.append((img_path, self.class_to_idx[class_name]))
        
        print(f"Found {len(self.samples)} images in {len(self.classes)} classes")
    
    def __len__(self):
        return len(self.samples)
    
    def __getitem__(self, idx):
        img_path, label = self.samples[idx]
        image = Image.open(img_path).convert('RGB')
        
        if self.transform:
            image = self.transform(image)
        
        return image, label

class EfficientNetClassifier(nn.Module):
    def __init__(self, num_classes):
        super().__init__()
        self.backbone = models.efficientnet_b0(pretrained=True)
        in_features = self.backbone.classifier[1].in_features
        self.backbone.classifier = nn.Sequential(
            nn.Dropout(0.2),
            nn.Linear(in_features, num_classes)
        )
    
    def forward(self, x):
        return self.backbone(x)

def train_model():
    # Paths
    TRAIN_DIR = "../images/train"
    VAL_DIR = "../images/val"
    TEST_DIR = "../images/test"
    
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"Using device: {device}")
    
    # Transforms
    train_transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.RandomHorizontalFlip(),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])
    
    val_transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])
    
    # Data
    train_dataset = FoodDataset(TRAIN_DIR, train_transform)
    val_dataset = FoodDataset(VAL_DIR, val_transform)
    test_dataset = FoodDataset(TEST_DIR, val_transform)
    
    train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True) # batch size
    val_loader = DataLoader(val_dataset, batch_size=32, shuffle=False)    # batch size
    test_loader = DataLoader(test_dataset, batch_size=32, shuffle=False)  # batch size
    
    # Model
    model = EfficientNetClassifier(num_classes=len(train_dataset.classes))
    model.to(device)
    
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=1e-4)
    
    best_val_acc = 0.0
    
    # Training
    for epoch in range(10): # epochs
        # Train
        model.train()
        for batch_idx, (images, labels) in enumerate(train_loader):
            images, labels = images.to(device), labels.to(device)
            
            optimizer.zero_grad()
            outputs = model(images)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            
            if batch_idx % 5 == 0:
                print(f'Epoch {epoch+1}, Batch {batch_idx}, Loss: {loss.item():.4f}')
        
        # Validate
        model.eval()
        correct = 0
        total = 0
        
        with torch.no_grad():
            for images, labels in val_loader:
                images, labels = images.to(device), labels.to(device)
                outputs = model(images)
                _, predicted = torch.max(outputs.data, 1)
                total += labels.size(0)
                correct += (predicted == labels).sum().item()
        
        val_accuracy = 100 * correct / total
        print(f'Epoch {epoch+1}: Val Accuracy: {val_accuracy:.2f}%')
        
        # Save best model
        if val_accuracy > best_val_acc:
            best_val_acc = val_accuracy
            torch.save(model.state_dict(), 'food_model.pth')
            print(f'New best model saved!')
    
    # Test
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
    
    print(f"\nFinal Results:")
    print(f"Best Val Accuracy: {best_val_acc:.2f}%")
    print(f"Test Accuracy: {test_accuracy:.2f}%")
    
    # Convert model to different formats
    print("\nConverting model to different formats...")
    
    # 1. TorchScript for mobile
    model.eval()
    dummy_input = torch.randn(1, 3, 224, 224).to(device)
    
    try:
        scripted_model = torch.jit.trace(model, dummy_input)
        scripted_model.save('food_model_mobile.pt')
        print("✓ Mobile model saved: food_model_mobile.pt")
    except Exception as e:
        print(f"✗ Mobile conversion failed: {e}")
    
    # 2. ONNX for web
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
    
    # 3. Save class mapping
    class_mapping = {
        "class_to_idx": train_dataset.class_to_idx,
        "idx_to_class": {str(v): k for k, v in train_dataset.class_to_idx.items()},
        "num_classes": len(train_dataset.classes)
    }
    
    import json
    with open('class_mapping.json', 'w') as f:
        json.dump(class_mapping, f, indent=2)
    
    print("✓ Class mapping saved: class_mapping.json")
    print("\nFiles ready for frontend:")
    print("- best_food_model.pth (Backend)")
    print("- food_model_mobile.pt (iOS/Android)")
    print("- food_model_web.onnx (Web/JS)")
    print("- class_mapping.json (All platforms)")

if __name__ == "__main__":
    train_model()