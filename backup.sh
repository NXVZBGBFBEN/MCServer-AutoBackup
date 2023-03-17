#!/bin/bash

##設定##
STARTER="/home/NX-EN/minecraft-server/start.sh" #サーバの起動スクリプトのパス
SCREEN="minecraft"                              #minecraftを実行しているscreen名

MC_DIR="/home/NX-EN/minecraft-server"     #バックアップしたいディレクトリのパス
BU_DIR="/home/NX-EN/MCServer-AutoBackup"  #このスクリプトがあるディレクトリのパス

BU_TIME=$(date +%Y%m%d-%H%M%S)  #コミットメッセージに入れる日時のフォーマット
BU_NAME="AutoBackup_${BU_TIME}" #コミットメッセージの名称

CNT1=300                    #サーバを自動停止する300秒前にお知らせ
CNT2=30                     #サーバが自動停止する30秒前にもう一度お知らせ
CNT3=120                    #サーバが完全に停止するまで120秒待機
########


##サーバの自動停止##
echo -e "\e[36m[ MCServer-AutoBackup ] Starting backup...\e[m"
screen -r $SCREEN -X stuff "say §9§lお知らせ\015"
echo -e "\e[36m[ MCServer-AutoBackup ] Waiting $CNT1 sec...\e[m"
screen -r $SCREEN -X stuff "say §3§l§o"$CNT1"§r§6秒後に§3§lバックアップ§r§6及び§3§l再起動§r§6を行います\015"
screen -r $SCREEN -X stuff "say §6セーブしてサーバから退出してください\015"
sleep $(expr $CNT1 - $CNT2)
screen -r $SCREEN -X stuff "say §c§l§o"$CNT2"§r§4§l秒後にサーバーが自動停止します\015"
sleep $CNT2
echo -e "\e[36m[ MCServer-AutoBackup ] Stopping minecraft server...\e[m"
screen -r $SCREEN -X stuff "stop\015"
sleep $CNT3

##サーバデータを同期する##
echo -e "\e[36m[ MCServer-AutoBackup ] Syncing minecraft-server data...\e[m"
rsync -av --delete $MC_DIR $BU_DIR/data

##git操作##
echo -e "\e[36m[ MCServer-AutoBackup ] git add\e[m"
git add -A
echo -e "\e[36m[ MCServer-AutoBackup ] git commit\e[m"
git commit -am "$BU_NAME"
echo -e "\e[36m[ MCServer-AutoBackup ] git push\e[m"
git push origin

##サーバの自動起動##
echo -e "\e[36m[ MCServer-AutoBackup ] Starting minecraft server...\e[m"
screen -r $SCREEN -X stuff "$STARTER\015"