# YOLOv8 Training - Clean Output Version
import os
import json
import torch
from ultralytics import YOLO
import shutil
import pandas as pd

def load_food_config(config_path="C:/Users/User/Documents/ProjectCalorie/backend/config/food_config.json"):
    """Load food classes from config file"""
    with open(config_path, 'r', encoding='utf-8') as f:
        config = json.load(f)
    
    class_names = config['class_names']
    print(f"Loaded {len(class_names)} food classes from {config_path}")
    return class_names

def rename_folders(class_names):
    """Rename numbered folders to food names"""
    base_paths = [
        'C:/Users/User/Documents/ProjectCalorie/backend/images/train',
        'C:/Users/User/Documents/ProjectCalorie/backend/images/val', 
        'C:/Users/User/Documents/ProjectCalorie/backend/images/test'
    ]
    
    print("Renaming folders...")
    
    for base_path in base_paths:
        if not os.path.exists(base_path):
            print(f"Path not found: {base_path}")
            continue
            
        for folder_id, food_name in class_names.items():
            folder_number = int(folder_id)
            old_path = os.path.join(base_path, str(folder_number))
            new_path = os.path.join(base_path, food_name)
            
            if os.path.exists(old_path):
                try:
                    os.rename(old_path, new_path)
                    print(f"Renamed: {folder_number} → {food_name}")
                except OSError as e:
                    print(f"Failed to rename {old_path}: {e}")

def train_model(
    dataset_path="C:/Users/User/Documents/ProjectCalorie/backend/images",
    config_path="C:/Users/User/Documents/ProjectCalorie/backend/config/food_config.json"
):
    """Train YOLOv8 model"""
    
    if not os.path.exists(dataset_path):
        print(f"Dataset not found: {dataset_path}")
        return None
    
    # Load food classes and rename folders
    class_names = load_food_config(config_path)
    rename_folders(class_names)
    
    # Load model
    device = 'cuda' if torch.cuda.is_available() else 'cpu'
    print(f"Using device: {device}")
    
    model = YOLO('yolov8n-cls.pt')
    
    # Train
    print("Starting training...")
    results = model.train(
        data=dataset_path,
        epochs=30,
        imgsz=288,
        batch=8,
        device=device,
        project='C:/Users/User/Documents/ProjectCalorie/backend/training',
        name='food_training',

        patience=15,     # Early stopping เร็วขึ้น
        save_period=5,   # Save ทุก 5 epochs
        plots=True,
        val=True
    )
    
    # Copy best model to models folder
    best_path = 'C:/Users/User/Documents/ProjectCalorie/backend/training/food_training/weights/best.pt'
    models_dir = 'C:/Users/User/Documents/ProjectCalorie/backend/models'
    final_path = os.path.join(models_dir, 'food_classifier.pt')
    
    os.makedirs(models_dir, exist_ok=True)
    
    if os.path.exists(best_path):
        shutil.copy2(best_path, final_path)
        print(f"Model saved: {final_path}")
        return final_path
    else:
        print(f"Best model not found at: {best_path}")
        return None

def get_training_metrics():
    """Show training metrics"""
    results_file = 'C:/Users/User/Documents/ProjectCalorie/backend/training/food_training/results.csv'
    confusion_matrix = 'C:/Users/User/Documents/ProjectCalorie/backend/training/food_training/confusion_matrix_normalized.png'
    
    print("\n" + "="*50)
    print("TRAINING RESULTS")
    print("="*50)
    
    if os.path.exists(results_file):
        try:
            df = pd.read_csv(results_file)
            last_row = df.iloc[-1]
            
            print("Final Metrics:")
            if 'metrics/precision(B)' in df.columns:
                print(f"Precision: {last_row['metrics/precision(B)']:.3f}")
            if 'metrics/recall(B)' in df.columns:
                print(f"Recall: {last_row['metrics/recall(B)']:.3f}")
            if 'metrics/mAP50(B)' in df.columns:
                print(f"F1-Score: {last_row['metrics/mAP50(B)']:.3f}")
            if 'val/loss' in df.columns:
                print(f"Validation Loss: {last_row['val/loss']:.3f}")
                
        except Exception as e:
            print(f"Could not read metrics: {e}")
            print("Check results.csv manually")
    
    if os.path.exists(confusion_matrix):
        print(f"Confusion Matrix: {confusion_matrix}")
    else:
        print("Confusion matrix not found")

def export_models(model_path):
    """Export models - .pt and .onnx only"""
    if not os.path.exists(model_path):
        print(f"Model not found: {model_path}")
        return
    
    model = YOLO(model_path)
    models_dir = 'C:/Users/User/Documents/ProjectCalorie/backend/models'
    
    print("Exporting models...")
    
    successful_exports = []
    
    # Export ONNX for React and Flutter
    try:
        print("Attempting ONNX export...")
        onnx_path = model.export(
            format='onnx',
            imgsz=224,
            simplify=False,
            dynamic=False,
            verbose=False
        )
        
        final_onnx = os.path.join(models_dir, 'food_classifier.onnx')
        if onnx_path and os.path.exists(onnx_path):
            if onnx_path != final_onnx:
                shutil.move(onnx_path, final_onnx)
            
            size_mb = os.path.getsize(final_onnx) / (1024*1024)
            print(f"✓ ONNX exported: {final_onnx} ({size_mb:.1f} MB)")
            successful_exports.append("ONNX")
        else:
            raise Exception("ONNX file not created")
            
    except Exception as e:
        print(f"✗ ONNX export failed: {e}")
    
    # Summary
    print(f"\n" + "="*50)
    print("EXPORT SUMMARY")
    print("="*50)
    
    print("Available model files:")
    print(f"  ✓ PyTorch (.pt): {model_path}")
    
    if successful_exports:
        for fmt in successful_exports:
            print(f"  ✓ {fmt}: Ready for frontend")
    else:
        print("  ✗ ONNX export failed - frontend will need alternative solution")
    
    print(f"\nExport completed!")

def clean_training_outputs():
    """Remove unnecessary files"""
    print("\nCleaning up unnecessary files...")
    
    cleanup_paths = [
        'C:/Users/User/Documents/ProjectCalorie/backend/models/tmp_tflite_int8_calibration_images.npy',
        'C:/Users/User/Documents/ProjectCalorie/backend/training/datasets',
        'C:/Users/User/Documents/ProjectCalorie/backend/training/imagenet10.zip',
        'C:/Users/User/Documents/ProjectCalorie/backend/yolo11n.pt',
        'C:/Users/User/Documents/ProjectCalorie/backend/yolov8n-cls.pt'
    ]
    
    for path in cleanup_paths:
        if os.path.exists(path):
            try:
                if os.path.isdir(path):
                    shutil.rmtree(path)
                else:
                    os.remove(path)
                print(f"Removed: {os.path.basename(path)}")
            except Exception as e:
                print(f"Could not remove {path}: {e}")

def show_final_structure():
    """Show final folder structure"""
    print("\n" + "="*50)
    print("FINAL OUTPUT FILES")
    print("="*50)
    
    models_dir = 'C:/Users/User/Documents/ProjectCalorie/backend/models'
    training_dir = 'C:/Users/User/Documents/ProjectCalorie/backend/training/food_training'
    
    print("Models folder:")
    if os.path.exists(models_dir):
        for file in os.listdir(models_dir):
            if file.endswith(('.pt', '.onnx', '.tflite')):
                file_path = os.path.join(models_dir, file)
                size_mb = os.path.getsize(file_path) / (1024*1024)
                print(f"  {file} ({size_mb:.1f} MB)")
    
    print("\nImportant training files:")
    important_files = [
        'confusion_matrix_normalized.png',
        'results.csv', 
        'results.png'
    ]
    
    if os.path.exists(training_dir):
        for file in important_files:
            file_path = os.path.join(training_dir, file)
            if os.path.exists(file_path):
                print(f"  {file}")

def main():
    """Main training function"""
    
    print("YOLOv8 Food Classifier Training")
    print("=" * 40)
    
    # Check config file
    config_path = "C:/Users/User/Documents/ProjectCalorie/backend/config/food_config.json"
    if not os.path.exists(config_path):
        print("food_config.json not found!")
        return
    
    # Train model
    model_path = train_model()
    
    if model_path:
        print("Training successful!")
        
        # Show metrics
        get_training_metrics()
        
        # Export models
        export_models(model_path)
        
        # Clean up
        clean_training_outputs()
        
        # Show final structure
        show_final_structure()
        
        print("\nReady for deployment!")
    else:
        print("Training failed!")

if __name__ == "__main__":
    main()