import { useState, useEffect } from "react";
import { User } from "../services/userModel";
import { adminAPI } from "../services/adminService";
import UserTableRow from "./UserTableRow";
import EditUserModal from "./EditUserModal";

// 1. เพิ่ม function handleDelete
const handleDelete = async (userId: number) => {
  if (!confirm("คุณแน่ใจหรือไม่ที่จะลบผู้ใช้นี้?")) return;

  try {
    setLoading(true);
    await adminAPI.deleteUser(userId); // เรียก API delete
    onUpdate(); // รีโหลดตาราง
  } catch (err: any) {
    console.error("Delete Error:", err);
    alert(err.message || "เกิดข้อผิดพลาดในการลบผู้ใช้");
  } finally {
    setLoading(false);
  }
};


export default function UserTable() {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [editingUser, setEditingUser] = useState<User | null>(null);

  const fetchUsers = async () => {
    setLoading(true);
    try {
      const data = await adminAPI.getAllUsers();
      setUsers(data);
    } catch (err) {
      console.error(err);
      alert("ไม่สามารถดึงข้อมูลผู้ใช้ได้");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const handleDelete = async (user_id: number) => {
    if (!confirm("คุณแน่ใจว่าจะลบผู้ใช้นี้?")) return;
    try {
      await adminAPI.deleteUser(user_id);
      fetchUsers();
    } catch (err) {
      console.error(err);
      alert("ไม่สามารถลบผู้ใช้ได้");
    }
  };

  const handleSave = () => {
    fetchUsers(); // รีโหลดตารางหลังแก้ไข
  };

  return (
    <div>
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Username</th>
            <th>Email</th>
            <th>Phone</th>
            <th>Age</th>
            <th>Gender</th>
            <th>Height</th>
            <th>Weight</th>
            <th>Goal</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {loading ? (
            <tr><td colSpan={10}>Loading...</td></tr>
          ) : users.length === 0 ? (
            <tr><td colSpan={10}>ไม่มีผู้ใช้</td></tr>
          ) : (
            users.map(user => (
              <UserTableRow
                key={user.user_id}
                user={user}
                onEdit={() => setEditingUser(user)}
                onDelete={() => handleDelete(user.user_id)}
              />
            ))
          )}
        </tbody>
      </table>

      {editingUser && (
        <EditUserModal
          user={editingUser}
          onClose={() => setEditingUser(null)}
          onSave={handleSave}
        />
      )}
    </div>
  );
}
