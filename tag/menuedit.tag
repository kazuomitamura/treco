menuedit
    input(type="text", size=28, placeholder="メニュー名", value="{menu_nm}", ref="menu_nm", style="padding: 0.5em")
    br
    br
    - for(i = 1; i <= 5; i++)
        .data-board
            .data-board-title 種目#{i}
            .data-board-body 
                p.content-title ウォーミングアップセット
                table
                    - wu1Nm  = "set" + i + "wu1_nm";
                    - wu1Cnt = "set" + i + "wu1_cnt";
                    - wu2Nm  = "set" + i + "wu2_nm";
                    - wu2Cnt = "set" + i + "wu2_cnt";
                    tr
                        td &nbsp&nbsp１.
                        td 
                            input(type="text", size=21, value="{" + wu1Nm + "}", ref=wu1Nm)
                        td 
                            input(type="tel", size=3, value="{" + wu1Cnt + "}", style="text-align:center", ref=wu1Cnt)
                        td 回
                    tr 
                        td &nbsp&nbsp２. 
                        td 
                            input(type="text", size=21, value="{" + wu2Nm + "}", ref=wu2Nm)
                        td
                            input(type="tel", size=3, value="{" + wu2Cnt + "}", style="text-align:center", ref=wu2Cnt)
                        td 回
                        
                    
            .data-board-body
                p.content-title 本番セット
                table
                    - nm       = "set" + i + "_nm";
                    - beginCnt = "set" + i + "begin_cnt";
                    - beginSet = "set" + i + "begin_set";
                    - lastCnt  = "set" + i + "last_cnt";
                    - lastSet  = "set" + i + "last_set";
                    tr
                        td
                            input(type="text", size=28, value="{" + nm + "}", ref=nm)
                    tr
                        td
                            table
                                tr
                                    td &nbsp&nbsp初回：
                                    td
                                        input(type="tel", size=3, value="{" + beginCnt + "}", style="text-align:center", ref=beginCnt)
                                        span 回
                                        input(type="tel", size=3, value="{" + beginSet + "}", style="text-align:center", ref=beginSet)
                                        span セット
                                tr
                                    td &nbsp&nbsp最終：
                                    td
                                        input(type="tel", size=3, value="{" + lastCnt + "}", style="text-align:center", ref=lastCnt)
                                        span 回
                                        input(type="tel", size=3, value="{" + lastSet + "}", style="text-align:center", ref=lastSet)
                                        span セット
                            
                        
    //- ツールバー
    .toolbar
        button.icon-reply.left(onclick="{back}") 戻る
        button.icon-close(onclick="{remove}", if="{menuCd!=-1}") 削除
        button.icon-save(onclick="{save}") 保存
        
        
        
    script.
        this.menuCd = parseInt(this.parent.menuCd);
        
        this.on('mount', () => {
            // メニュー詳細データ取得
            if (parseInt(this.menuCd) === -1) {
                this.sort_no = -1;
                return;
            }
            
            var self = this;
            fetch('/treco/read_menuedit', {
                method: 'POST'
                , body: JSON.stringify({
                    menuCd: self.menuCd
                })
                , headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                }
                , credentials: "include"
            }).then(function(data) {
                return data.json();
            }).then(function(json) {
                self.menu_nm = json.menu_nm
                self.sort_no = json.sort_no
                for (var i = 1; i <=5; i++) {
                    self['set' + i + '_nm'] = json['set' + i + '_nm'];
                    self['set' + i + 'wu1_nm']  = json['set' + i + 'wu1_nm'];
                    self['set' + i + 'wu1_cnt'] = json['set' + i + 'wu1_cnt'];
                    self['set' + i + 'wu2_nm']  = json['set' + i + 'wu2_nm'];
                    self['set' + i + 'wu2_cnt'] = json['set' + i + 'wu2_cnt'];
                    self['set' + i + 'begin_cnt'] = json['set' + i + 'begin_cnt'];
                    self['set' + i + 'begin_set'] = json['set' + i + 'begin_set'];
                    self['set' + i + 'last_cnt']  = json['set' + i + 'last_cnt'];
                    self['set' + i + 'last_set']  = json['set' + i + 'last_set'];
                }
                self.update();
            });
        });

        
        // 戻るボタン
        this.back = () => {
            var res = confirm('入力を破棄して前の画面に戻りますか？');
            if (res) {
                var r = this.parent.route.create();
                r('menulist');
                this.update();
            }
        }
        
        // 削除ボタン
        this.remove = () => {
            var res = confirm('メニューを削除しますか？');
            if (res === false) return;
            
            // データを削除する
            var self = this;
            fetch('/treco/write_removeMenu', {
                method: 'POST'
                , body: JSON.stringify({menuCd: this.menuCd})
                , headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                }
                , credentials: "include"
            }).then(() => {
                alert('メニューを削除しました。');
                var r = this.parent.route.create();
                r('menulist');
                this.update();
            });
        }
        
        // 保存ボタン
        this.save = () => {
            var res = confirm('メニューを保存しますか？');
            if (res === false) return;
            
            // 保存する値を取得する
            var body: any = {};
            body.menuCd = this.menuCd;
            body.menu_nm = this.refs.menu_nm.value;
            body.sort_no = this.sort_no;
            for (var i = 1; i <= 5; i++) {
                body['set' + i + '_nm']       =          this.refs['set' + i + '_nm'].value;
                body['set' + i + 'wu1_nm']    =          this.refs['set' + i + 'wu1_nm'].value;
                body['set' + i + 'wu1_cnt']   = parseInt(this.refs['set' + i + 'wu1_cnt'].value);
                body['set' + i + 'wu2_nm']    =          this.refs['set' + i + 'wu2_nm'].value;
                body['set' + i + 'wu2_cnt']   = parseInt(this.refs['set' + i + 'wu2_cnt'].value);
                body['set' + i + 'begin_cnt'] = parseInt(this.refs['set' + i + 'begin_cnt'].value);
                body['set' + i + 'begin_set'] = parseInt(this.refs['set' + i + 'begin_set'].value);
                body['set' + i + 'last_cnt']  = parseInt(this.refs['set' + i + 'last_cnt'].value);
                body['set' + i + 'last_set']  = parseInt(this.refs['set' + i + 'last_set'].value);
            }
            Object.keys(body).forEach((key: string) => {
                if (body[key] !== body[key]) body[key] = null;
            });
            
            // データを保存する
            var self = this;
            fetch('/treco/write_menuedit', {
                method: 'POST'
                , body: JSON.stringify(body)
                , headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                }
                , credentials: "include"
            }).then(() => {
                alert('メニューを保存しました。');
                var r = this.parent.route.create();
                r('menulist');
                this.update();
            });
        }
        
