# Aturan Proguard untuk mencegah error missing classes dari Google ML Kit
# ML Kit plugin secara default memiliki referensi ke kelas bahasa lain yang tidak kita gunakan (Chinese, Japanese, dll).
# Karena kita hanya memakai skrip Latin, kelas tersebut tidak dimasukkan ke final APK. 
# Aturan ini memberi tahu R8 (minifier) untuk mengabaikan peringatan tersebut.

-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
