# confirm-backup-nas2aws
## 概要
ARONAS->AWSへのバックアップ処理後の確認作業に使用するスクリプト群です。  
## 使用手順
※/ARONAS/Archives/ISR/SystemAssistant/yearlyOperations/nas2awsBackup/にこのリポジトリをクローンした場合の例です。 
### NASのファイルリストを取得する
- listOutput.shをテキストエディタで開き、実行したいスクリプトの行の頭の'#'を消して保存してください。
- mac OSのターミナルを起動し、下記のコマンドを実行してください。/ARONAS/Archives/ISR/SystemAssistant/yearlyOperations/nas2awsBackupに結果のファイルが出力されます。
```
ssh NASのユーザー名@NASのIPアドレス
cd /share/Archives/ISR/SystemAssistant/yearlyOperations/nas2awsBackup/confirm-backup-nas2aws/programs
sh listOutput.sh
exit
```
### awsのファイルリストを取得する
- aws cliがインストールされていることを前提とします。
- Finderの「サーバに接続」でNASにSMB接続してください。
- getAwsFileInfo.shをテキストエディタ等で開き、実行したいスクリプトの行の頭の'#'を消して保存してください。
- mac OSのターミナルを起動し、下記のコマンドを実行してください。/ARONAS/Archives/ISR/SystemAssistant/yearlyOperations/nas2awsBackupに結果のファイルが出力されます。
```
cd /Volumes/Archives/ISR/SystemAssistant/yearlyOperations/nas2awsBackup/confirm-backup-nas2aws/programs
sh getAwsFileInfo.sh
```
### ファイルリストを比較する
- tidyverse, data.table, here パッケージがインストールされていることを前提とします。
- R Studioを起動し、メニューのFile > New project > Existing Directoryを選択してください。
- /ARONAS/Archives/ISR/SystemAssistant/yearlyOperations/nas2awsBackup/confirm-backup-nas2awsを選択し、Create Projectをクリックしてください。
- confirm-backup-result.Rを開いてください。
- 'kTargetFolders <- 'を検索してください。ターゲットのフォルダ名を確認し、追加、削除してください。
- sourceをクリックしてください。コンソールに結果が出力されます。
