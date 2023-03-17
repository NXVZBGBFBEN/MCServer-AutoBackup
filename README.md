# MCServer-AutoBackup

マイクラサーバの全自動バックアップスクリプトです．  
GitHub上にサーバをフォルダごと丸々コピーします．  
このスクリプトは，[木更津高専22s](https://github.com/NITKC22s)内で運営しているMinecraftサーバ用に作ったものを一般向けに改修したものです．

## 運用条件

<table>
  <tbody>
    <tr>
      <td>OS</td>
      <td>Linux</td>
    </tr>
    <tr>
      <td>シェル</td>
      <td>GNU/Bash</td>
    </tr>
    <tr>
      <td>Minecraft</td>
      <td>
        Java Edition<br>
        (<code>screen</code>を用いたバックグラウンド起動)
      </td>
    </tr>
  </tbody>
</table>

## 依存ソフトウェア

本スクリプトの設定および動作に必要なコマンド類です．  
事前に下記コマンドが使用できることを確認してください．

+ `git`
+ `rsync`
+ `screen`
+ `sleep`
+ `ssh`
+ `ssh-keygen`
+ シェルスクリプトを定期実行できるソフトウェア  
  (利用手順の説明では`crontab`(cron)を用います．)
+ コードエディタ
  (利用手順の説明ではVimを使います．~~全人類Vim使うべき~~)

## 利用手順

このスクリプトを利用する手順を示します．

#### I. テンプレートを使用してリポジトリを作成する

1. *Use this repository* から，*Create a new repository* を選択します．
   ![image](https://user-images.githubusercontent.com/107386214/225204968-14f4bfec-c034-4981-b415-5f0294e2e309.png)  

2. *Repository name* に自由な名前を入れ，各種設定を確認したら *Create repository from template* を押します．
   (基本的に *Include all branches* にはチェックを入れないでください．)
   ![image](https://user-images.githubusercontent.com/107386214/225206047-bcff38b0-b3f3-4693-8618-ea594e91b7e0.png)  

#### II. リポジトリのクローンとGitの設定をする

1. SSH接続用の鍵を生成します．このとき，パスフレーズは設定しないでください．

   ```
   $ cd ~/.ssh
   $ ssh-keygen -t ed25519 -C "[メールアドレス]"
   ```

2. リポジトリの設定ページにSSH公開鍵を登録します．
   ![image](https://user-images.githubusercontent.com/107386214/225823608-416e1ea3-64ce-4aee-9100-ae607dc54e02.png)  
   ![image](https://user-images.githubusercontent.com/107386214/225823779-7919e8e9-00f3-41d6-b9bd-00befc893cd4.png)  
   ![image](https://user-images.githubusercontent.com/107386214/225823873-c311757d-2e8f-450a-a600-13de8d105290.png)  
   *Title* に鍵の名前を入力し，*Key* に公開鍵を貼り付けて *Allow write access* にチェックを入れて *Add Key* を押します．
   ![image](https://user-images.githubusercontent.com/107386214/225823963-79cac59f-b513-493a-b423-589b1ec4af0a.png)  

3. `config`にSSH秘密鍵の設定を追記します．

   ```
   $ cd ~/.ssh
   $ vim ./config
   ```
   
   ```
   Host github.com
      HostName github.com
      IdentityFile ~/.ssh/[秘密鍵名]
      User git
   ```

4. リポジトリをローカルにクローンします．  
   *Code* から *SSH* を選択し，リンクをコピーします．
   ![image](https://user-images.githubusercontent.com/107386214/225585893-1d0cc8cc-75e2-4e34-852c-2dc0f64b636c.png)  

   ```
   $ cd [クローン先の親ディレクトリ]
   $ git clone [コピーしたリンク]
   ```

#### III. 環境設定をする

1. リポジトリ内にある`backup.sh`を開き，スクリプトの設定を変更します．

   ```shell
   #!/bin/bash
   
   ##設定##
   STARTER="/root/minecraft-server/start.sh" #サーバの起動スクリプトのパス
   SCREEN="minecraft"                        #minecraftを実行しているscreen名
   
   MC_DIR="/root/minecraft-server"     #バックアップしたいディレクトリのパス
   BU_DIR="/root/MCServer-AutoBackup"  #このスクリプトがあるディレクトリのパス
   
   BU_TIME=$(date +%Y%m%d-%H%M%S)  #コミットメッセージに入れる日時のフォーマット
   BU_NAME="AutoBackup_${BU_TIME}" #コミットメッセージの名称
   
   CNT1=300                    #サーバを自動停止する300秒前にお知らせ
   CNT2=30                     #サーバが自動停止する30秒前にもう一度お知らせ
   CNT3=120                    #サーバが完全に停止するまで120秒待機
   ########
   ```
   
   + 誤作動を防ぐため，ディレクトリの指定には**絶対パス**を用いてください．
   + `MC_DIR`のパスの最後に`/`をつけると，`data`ディレクトリ以下に指定したディレクトリの中身だけがコピーされます．  
      つけない場合は，`MC_DIR`に指定したディレクトリごと`data`以下にコピーされます．
   + `CNT3`に設定した値は，サーバに`stop`コマンドを送ってからファイルのコピーを開始するまでの待機時間です．

2. スクリプトに実行権限を付与します．

   ```
   $ chmod 755 ./backup.sh
   ```

3. スクリプトを単体で実行して，正常に動作することを確認します．

   ```
   $ ./backup.sh
   ```

#### IV. 定期実行を設定する

1. ログの出力先ファイルを作成します．

   ```
   $ cd /var/log
   $ sudo touch mcbackup.log
   $ sudo chmod 666 ./mcbackup.log
   ```

2. `crontab`を用いて定期実行のスケジュールを設定します．~~詳細はググってください~~  
   例: 毎日03:10にバックアップを実行する

   ```
   $ crontab -e
   ```
   
   ```
   10 03 * * * cd [BU_DIRに設定したパス] && ./backup.sh > /var/log/mcbackup.log 2>&1
   ```

## License

This project is licensed under the MIT License,
see the [LICENSE](https://github.com/NXVZBGBFBEN/MCServer-AutoBackup/blob/develop/LICENSE) file for details.