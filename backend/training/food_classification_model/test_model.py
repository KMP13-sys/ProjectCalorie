import torch
import torch.nn as nn
from torch.utils.data import DataLoader
from torchvision import transforms, datasets
import numpy as np
from sklearn.metrics import classification_report, confusion_matrix
import pandas as pd

# Configuration
MODEL_PATH = r"C:\Users\User\Documents\ProjectCalorie\backend\models\food_classification_model\food_model.pth"  # แก้ path ของ model
TEST_DATA_PATH = r"C:\Users\User\Documents\ProjectCalorie\backend\images\test"        # แก้ path ของ test data
NUM_CLASSES = 100
BATCH_SIZE = 32

def load_model():
    """Load trained EfficientNet model"""
    from torchvision.models import efficientnet_b0
    
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    
    # Load checkpoint first to check structure
    checkpoint = torch.load(MODEL_PATH, map_location=device)
    
    # Debug: Print checkpoint keys
    print("Checkpoint keys:", list(checkpoint.keys())[:5], "...")
    
    # Create model
    model = efficientnet_b0(pretrained=False)
    model.classifier[1] = nn.Linear(model.classifier[1].in_features, NUM_CLASSES)
    
    try:
        # Try loading directly
        model.load_state_dict(checkpoint)
        print("Direct loading successful!")
    except RuntimeError as e:
        print(f"Direct loading failed: {e}")
        
        # Try different loading methods
        if 'model_state_dict' in checkpoint:
            print("Loading from 'model_state_dict' key...")
            model.load_state_dict(checkpoint['model_state_dict'])
        elif 'state_dict' in checkpoint:
            print("Loading from 'state_dict' key...")
            model.load_state_dict(checkpoint['state_dict'])
        elif 'model' in checkpoint:
            print("Loading from 'model' key...")
            model.load_state_dict(checkpoint['model'])
        else:
            # Handle different key prefixes
            print("Trying to fix key names...")
            model_dict = model.state_dict()
            
            # Create mapping for different prefixes
            new_checkpoint = {}
            
            for checkpoint_key, checkpoint_value in checkpoint.items():
                # Remove 'backbone.' prefix if present
                if checkpoint_key.startswith('backbone.'):
                    new_key = checkpoint_key.replace('backbone.', '')
                    if new_key in model_dict and model_dict[new_key].shape == checkpoint_value.shape:
                        new_checkpoint[new_key] = checkpoint_value
                
                # Remove 'model.' prefix if present
                elif checkpoint_key.startswith('model.'):
                    new_key = checkpoint_key.replace('model.', '')
                    if new_key in model_dict and model_dict[new_key].shape == checkpoint_value.shape:
                        new_checkpoint[new_key] = checkpoint_value
                
                # Direct match
                elif checkpoint_key in model_dict and model_dict[checkpoint_key].shape == checkpoint_value.shape:
                    new_checkpoint[checkpoint_key] = checkpoint_value
            
            if new_checkpoint:
                model.load_state_dict(new_checkpoint, strict=False)
                print(f"✅ Loaded {len(new_checkpoint)}/{len(model_dict)} parameters")
            else:
                print("❌ No matching parameters found")
                print("Model keys example:", list(model_dict.keys())[:3])
                print("Checkpoint keys example:", list(checkpoint.keys())[:3])
                raise RuntimeError("Cannot load model - key mismatch")
    
    model.to(device)
    model.eval()
    
    return model, device

def prepare_test_data():
    """Prepare test data"""
    test_transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], 
                           std=[0.229, 0.224, 0.225])
    ])
    
    test_dataset = datasets.ImageFolder(
        root=TEST_DATA_PATH,
        transform=test_transform
    )
    
    test_loader = DataLoader(
        test_dataset,
        batch_size=BATCH_SIZE,
        shuffle=False
    )
    
    # Get class names
    class_names = test_dataset.classes
    
    return test_loader, class_names

def evaluate_model():
    """Run evaluation and get predictions"""
    print("Loading model...")
    model, device = load_model()
    
    print("Loading test data...")
    test_loader, class_names = prepare_test_data()
    
    print("Running evaluation...")
    y_true = []
    y_pred = []
    
    with torch.no_grad():
        for images, labels in test_loader:
            images, labels = images.to(device), labels.to(device)
            outputs = model(images)
            _, predicted = torch.max(outputs, 1)
            
            y_true.extend(labels.cpu().numpy())
            y_pred.extend(predicted.cpu().numpy())
    
    return np.array(y_true), np.array(y_pred), class_names

def save_results_to_csv(y_true, y_pred, class_names):
    """Calculate metrics and save to CSV + Plot confusion matrix"""
    import matplotlib.pyplot as plt
    import seaborn as sns
    
    # 1. Overall metrics
    accuracy = (y_true == y_pred).mean()
    print(f"Test Accuracy: {accuracy:.4f} ({accuracy*100:.2f}%)")
    
    # 2. Classification report
    report = classification_report(
        y_true, y_pred, 
        target_names=class_names,
        output_dict=True,
        zero_division=0
    )
    
    # 3. Confusion Matrix Plot
    cm = confusion_matrix(y_true, y_pred)
    
    # Plot confusion matrix
    plt.figure(figsize=(12, 10))
    sns.heatmap(cm, 
                annot=False,  # Too many classes for numbers
                cmap='Blues',
                square=True,
                cbar_kws={'label': 'Count'})
    
    plt.title(f'Confusion Matrix - {NUM_CLASSES} Food Classes\nAccuracy: {accuracy*100:.2f}%', 
              fontsize=16, pad=20)
    plt.xlabel('Predicted Label', fontsize=12)
    plt.ylabel('True Label', fontsize=12)
    
    # Add grid for better readability
    plt.grid(True, alpha=0.3)
    
    # Save high-quality image
    plt.tight_layout()
    plt.savefig('confusion_matrix.png', dpi=300, bbox_inches='tight')
    plt.savefig('confusion_matrix.pdf', bbox_inches='tight')  # Vector format
    plt.show()
    
    print("📊 Confusion matrix saved as:")
    print("   - confusion_matrix.png (high-res)")
    print("   - confusion_matrix.pdf (vector)")
    
    # 4. Per-class results to DataFrame
    results_data = []
    for i, class_name in enumerate(class_names):
        if class_name in report:
            metrics = report[class_name]
            results_data.append({
                'Class_ID': i,
                'Class_Name': class_name,
                'Precision': round(metrics['precision'], 4),
                'Recall': round(metrics['recall'], 4),
                'F1_Score': round(metrics['f1-score'], 4),
                'Support': int(metrics['support'])
            })
    
    # 5. Add overall metrics
    results_data.append({
        'Class_ID': 'MACRO_AVG',
        'Class_Name': 'Macro Average',
        'Precision': round(report['macro avg']['precision'], 4),
        'Recall': round(report['macro avg']['recall'], 4),
        'F1_Score': round(report['macro avg']['f1-score'], 4),
        'Support': int(report['macro avg']['support'])
    })
    
    results_data.append({
        'Class_ID': 'WEIGHTED_AVG',
        'Class_Name': 'Weighted Average',
        'Precision': round(report['weighted avg']['precision'], 4),
        'Recall': round(report['weighted avg']['recall'], 4),
        'F1_Score': round(report['weighted avg']['f1-score'], 4),
        'Support': int(report['weighted avg']['support'])
    })
    
    results_data.append({
        'Class_ID': 'OVERALL',
        'Class_Name': 'Overall Accuracy',
        'Precision': round(accuracy, 4),
        'Recall': round(accuracy, 4),
        'F1_Score': round(accuracy, 4),
        'Support': len(y_true)
    })
    
    # 6. Save detailed results CSV
    df = pd.DataFrame(results_data)
    df.to_csv('model_evaluation_results.csv', index=False, encoding='utf-8')
    
    # 7. Plot top/bottom performing classes
    df_classes = df[df['Class_ID'] != 'MACRO_AVG']
    df_classes = df_classes[df_classes['Class_ID'] != 'WEIGHTED_AVG'] 
    df_classes = df_classes[df_classes['Class_ID'] != 'OVERALL']
    df_classes = df_classes.sort_values('F1_Score', ascending=False)
    
    # Top 15 and Bottom 15 classes
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(15, 12))
    
    # Top 15
    top_15 = df_classes.head(15)
    bars1 = ax1.bar(range(len(top_15)), top_15['F1_Score'], color='green', alpha=0.7)
    ax1.set_title('Top 15 Best Performing Classes', fontsize=14)
    ax1.set_ylabel('F1-Score')
    ax1.set_xticks(range(len(top_15)))
    ax1.set_xticklabels(top_15['Class_Name'], rotation=45, ha='right')
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(0, 1)
    
    # Add value labels on bars
    for i, bar in enumerate(bars1):
        height = bar.get_height()
        ax1.text(bar.get_x() + bar.get_width()/2., height + 0.01,
                f'{height:.3f}', ha='center', va='bottom', fontsize=9)
    
    # Bottom 15
    bottom_15 = df_classes.tail(15)
    bars2 = ax2.bar(range(len(bottom_15)), bottom_15['F1_Score'], color='red', alpha=0.7)
    ax2.set_title('Bottom 15 Worst Performing Classes', fontsize=14)
    ax2.set_ylabel('F1-Score')
    ax2.set_xlabel('Food Classes')
    ax2.set_xticks(range(len(bottom_15)))
    ax2.set_xticklabels(bottom_15['Class_Name'], rotation=45, ha='right')
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, 1)
    
    # Add value labels on bars
    for i, bar in enumerate(bars2):
        height = bar.get_height()
        ax2.text(bar.get_x() + bar.get_width()/2., height + 0.01,
                f'{height:.3f}', ha='center', va='bottom', fontsize=9)
    
    plt.tight_layout()
    plt.savefig('class_performance.png', dpi=300, bbox_inches='tight')
    plt.show()
    
    print("\n✅ Results saved:")
    print("📄 model_evaluation_results.csv - Detailed metrics")
    print("📊 confusion_matrix.png/.pdf - Confusion matrix")
    print("📊 class_performance.png - Best/worst classes")
    
    # 8. Print summary
    print(f"\n📊 Summary:")
    print(f"Test Accuracy: {accuracy*100:.2f}%")
    print(f"Macro F1-Score: {report['macro avg']['f1-score']*100:.2f}%")
    print(f"Weighted F1-Score: {report['weighted avg']['f1-score']*100:.2f}%")
    
    return df

if __name__ == "__main__":
    # Run evaluation
    y_true, y_pred, class_names = evaluate_model()
    
    # Save results
    results_df = save_results_to_csv(y_true, y_pred, class_names)
    
    print("\n🎉 Evaluation completed!")