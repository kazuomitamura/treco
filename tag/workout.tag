workout
    p(style="text-decoration: underline") {menuNm}
    br
    p
        date-select(ref="date")
    br
    .data-board(each="{item}")
        .data-board-title {setNm}
        .data-board-body 
            .content
                p ウォーミングアップ
                table
                    tr
                        td.icon-angle-right &nbsp{wu1Nm}
                        td ：
                        td {wu1Cnt}回
                    tr
                        td.icon-angle-right &nbsp{wu2Nm}
                        td ：
                        td {wu2Cnt}回
            .content(style="text-decoration: underline; font-weight: bold;")
                span 目標：
                span {goalCnt}回 × {goalSet}セット
            .content
                table.workout
                    thead
                        td(colspan=2) 今回
                        td 前回
                        td 前々回
                    tr(each="{count}")
                        td
                            input(type="tel", size=5, value="{cnt}", ref="cnt", data-setno="{setNo}", data-no="{no}", onchange="{calcRate}")
                        td.rate {Math.round(cnt / goalCnt * 1000) / 10}%
                        td {prev1}
                        td {prev2}
            .content
                span 次回：
                input(type="tel", size=4, value="{nextCnt}", data-setno="{setNo}", onchange="{setNextCnt}", ref="nextCnt")
                span 回
                input(type="tel", size=4, value="{nextSet}", data-setno="{setNo}", onchange="{setNextSet}", ref="nextSet")
                span セット
    textarea(rows=3, onchange="{setNote}") {note}
    
    //- ツールバー
    .toolbar
        button.icon-reply.left(onclick="{back}") 戻る
        button.icon-close(onclick="{remove}") 削除
        button.icon-save(onclick="{save}") 保存
        
    
    style(type="stylus").
        .content
            margin-bottom 0.75em
            input
                color #482404
                text-align center
        table.workout
            width 100%
            td 
                text-align center
                min-width 4em
                    
            thead td
                background-color #f6f3e9
                border 1px solid white
                padding 0.5em 0
                
            .rate
                font-size 0.8em
        textarea
            width 98%
                
                
                
    script.
        this.menuCd = this.parent.menuCd;
        this.date = this.parent.date;   // menumainで設定される
        
        this.on('mount', () => {
            // 初期日付設定
            this.refs.date.date = this.parent.date;
            this.refs.date.update();
            
            // IDと日付からデータを取得して、画面に表示する
            var self = this;
            fetch('/treco/read_workout', {
                method: 'POST'
                , body: JSON.stringify({
                    menuCd: this.menuCd
                    , date: this.date
                })
                , headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                }
                , credentials: "include"
            }).then(function(data) {
                return data.json();
            }).then(function(json) {
                self.item = json;
                self.menuNm = json[0].menuNm
                self.note = json[0].note
                self.update();
            });
        });
        
        // 回数を保存して、パーセンテージを算出する
        this.calcRate = (e: any) => {
            var setNo = parseInt(e.currentTarget.getAttribute('data-setno'));
            var no    = parseInt(e.currentTarget.getAttribute('data-no'));
            this.item[setNo - 1].count[no - 1].cnt = e.currentTarget.value;
            this.update();
        }
        // 次回の回数を保存する
        this.setNextCnt = (e: any) => {
            var setNo = parseInt(e.currentTarget.getAttribute('data-setno'));
            this.item[setNo - 1].nextCnt = e.currentTarget.value;
        }
        // 次回のセット数を保存する
        this.setNextSet = (e: any) => {
            var setNo = parseInt(e.currentTarget.getAttribute('data-setno'));
            this.item[setNo - 1].nextSet = e.currentTarget.value;
        }
        // ノートを保存する
        this.setNote = (e: any) => {
            this.note = e.currentTarget.value;
        }
        
        // 戻るボタン
        this.back = () => {
            var res = confirm('入力を破棄して前の画面に戻りますか？');
            if (res) {
                var r = this.parent.route.create();
                r('menumain');
                this.update();
            }
        }
        
        // 削除ボタン
        this.remove = () => {
            var res = confirm('この日のトレーニング履歴を削除しますか？');
            if (res === false) return;
            
            // データを削除する
            var self = this;
            fetch('/treco/write_removeWorkout', {
                method: 'POST'
                , body: JSON.stringify({
                    menuCd: self.menuCd
                    , date: self.date
                })
                , headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                }
                , credentials: "include"
            }).then(() => {
                alert('トレーニング履歴を削除しました。');
                var r = this.parent.route.create();
                r('menumain');
                this.update();
            });
        }
        
        // 保存ボタン
        this.save = () => {
            var res = confirm('トレーニング履歴を保存しますか？');
            if (res === false) return;
            
            // 次回のゴールが設定されていなければ中止
            for (var i = 0; i < this.item.length; i++) {
                if (this.item[i].nextCnt === void 0 || this.item[i].nextCnt === '' || this.item[i].nextSet === void 0 || this.item[i].nextSet === '') {
                    alert('次回のゴールを設定してください。');
                    this.refs.nextCnt[i].focus();
                    return;
                }
            }
            
            // 入力されたデータを保存する
            // 日付が変わっている場合、元日付のデータは削除して新しい日付で保存する。
            // その場合、新しい日付にすでにデータがあれば、メッセージを出して確認する。
            
            // 新しい日付のデータを確認する
            var newDate = this.refs.date.date;
            var self = this;
            fetch('/treco/read_isWorkout', {
                method: 'POST'
                , body: JSON.stringify({
                    menuCd: self.menuCd
                    , date: newDate
                })
                , headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                }
                , credentials: "include"
            }).then(function(data) {
                return data.json();
            }).then(function(json) {
                if (json.isWorkout) {
                    if (confirm('すでにデータが存在します。上書きしますか？') === false) return;
                }
                
                // データを削除する
                return fetch('/treco/write_removeWorkout', {
                    method: 'POST'
                    , body: JSON.stringify({
                        menuCd: self.menuCd
                        , date: newDate
                    })
                    , headers: {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json'
                    }
                    , credentials: "include"
                });
            }).then(function(json) {
                // 古いデータを削除する
                if (self.date !== newDate) {
                    return fetch('/treco/write_removeWorkout', {
                        method: 'POST'
                        , body: JSON.stringify({
                            menuCd: self.menuCd
                            , date: self.date
                        })
                        , headers: {
                            'Accept': 'application/json',
                            'Content-Type': 'application/json'
                        }
                        , credentials: "include"
                    });
                }
            }).then(function() {
                // データを保存する
                var set: any = [];
                for (var i = 0; i < self.item.length; i++) {
                    set.push({});
                    set[i].setNo = i;
                    set[i].nextCnt = self.item[i].nextCnt;
                    set[i].nextSet = self.item[i].nextSet;
                    for (var j = 0; j < 5; j++) {
                        set[i]["cnt" + (j + 1)] = self.item[i].count[j].cnt;
                    }
                }
                return fetch('/treco/write_saveWorkout', {
                    method: 'POST'
                    , body: JSON.stringify({
                        menuCd: self.menuCd
                        , date: newDate
                        , note: self.note
                        , set: set
                    })
                    , headers: {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json'
                    }
                    , credentials: "include"
                });
            }).then(() => {
                alert('トレーニング履歴を保存しました。');
                var r = self.parent.route.create();
                r('menumain');
                self.update();
            });
            
        }
        
        
        
    