#!/bin/bash

##設定##
SRV="server.jar" #サーバ本体のファイル名
SCR="minecraft"  #minecraftを実行しているscreen名

MC_DIR="/root/minecraft-server"     #サーバの実行ファイルがあるディレクトリのパス
BU_DIR="/root/MCServer-AutoBackup"  #このスクリプトがあるディレクトリのパス

BU_TIME=$(date +%Y%m%d-%H%M%S)  #コミットメッセージに入れる日時のフォーマット
BU_NAME="AutoBackup_${BU_TIME}" #コミットメッセージの名称

CNT1=300                    #サーバを自動停止する300秒前にお知らせ
CNT2=$(expr $CNT1 - $CNT3)  #サーバが自動停止する30秒前になるまで(270秒間)待機
CNT3=30                     #サーバが自動停止する30秒前にもう一度お知らせ
CNT4=120                    #サーバが完全に停止するまで120秒待機
########


##サーバの自動停止##
echo -e "\e[36m[ MCServer-AutoBackup ] Starting backup...\e[m"
screen -r $SCR -X stuff "say §9§lお知らせ\015"
echo -e "\e[36m[ MCServer-AutoBackup ] Waiting $CNT1 sec...\e[m"
screen -r $SCR -X stuff "say §3§l§o"$CNT1"§r§6秒後に§3§lバックアップ§r§6及び§3§l再起動§r§6を行います\015"
screen -r $SCR -X stuff "say §6セーブしてサーバから退出してください\015"
sleep $CNT2
screen -r $SCR -X stuff "say §c§l§o"$CNT3"§r§4§l秒後にサーバーが自動停止します\015"
sleep $CNT3
echo -e "\e[36m[ MCServer-AutoBackup ] Stopping minecraft server...\e[m"
screen -r $SCR -X stuff "stop\015"
sleep $CNT4

##サーバデータを同期する##
echo -e "\e[36m[ MCServer-AutoBackup ] Syncing minecraft-server data...\e[m"
rsync -av --delete $MC_PATH $BU_PATH/data

##git操作##
echo -e "\e[36m[ MCServer-AutoBackup ] git add\e[m"
git add -A
echo -e "\e[36m[ MCServer-AutoBackup ] git commit\e[m"
git commit -am "$BU_NAME"
echo -e "\e[36m[ MCServer-AutoBackup ] git push\e[m"
git push origin

##サーバの自動起動##
echo -e "\e[36m[ MCServer-AutoBackup ] Starting minecraft server...\e[m"
screen -r $SCR -X stuff "cd $MC_DIR\015"
screen -r $SCR -X stuff "./start.sh\015"