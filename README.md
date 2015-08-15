# LeapLogger
## これは何？
Leap Motionの毎フレームの位置や速度情報をCSVに出力するものです。  
Mac OS X上で動作します。  
ユーザディレクトリ配下のDocumentsディレクトリに、
「LeapLog」と言うディレクトリを作成し、そこに日付と時間でcsvファイルを出力します。  
GUIには認識中の手の数が表示されます。

## ビルド方法
LeapSDKから必要なファイルをプロジェクトに追加する。  
以下のファイル  
・LeapObjectiveC.mm  
・LeapObjectiveC.h  
・Leap.h  
・LeapMath.h  
・libLeap.dylib  
