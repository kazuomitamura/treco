menulist
    .data-board
        .data-board-title メニュー管理
        .data-board-body 
            table
                tr(each="{item}")
                    td.button
                        button.up(onclick="{up}", data-no="{no}", ref="up") ↑
                        button.down(onclick="{down}", data-no="{no}", ref="down") ↓
                    td.title
                        span ・
                        a(href="#menuedit/{menu_cd}") {menu_nm}
    //- ツールバー
    .toolbar
        button.icon-reply.left(onclick="{back}") 戻る
        button.icon-plus(onclick="{add}") 追加
        
        
    style(type="stylus").
        .data-board-title
            border-top-color black !important
        .data-board-body 
            table
                width 100%
                tr:first-child td button.up
                    display none
                tr:last-child td button.down
                    display none
                td
                    height 2em
                td.button
                    width 4em
                    text-align right
                    button
                        padding 0.5em 0.25em
                        background-color transparent
                        border 1px solid transparent
                        &:hover
                            color #8b9a2f
                            background-color white
                            border 1px solid #ddd5c2
                        &:active
                            color white
                            background-color #8b9a2f
                    
            
            
    script.
        // メニューを作成する
        this.on('mount', () => {
            // メニューデータ取得
            var self = this;
            fetch('/treco/read_menulist', {
                credentials: "include"
            }).then(function(data) {
                return data.json();
            }).then(function(json) {
                for (var i = 0; i < json.length; i++) {
                    json[i].no = i;
                }
                self.item = json;
                self.update();
            });
        });
        
                
        // 上ボタン
        this.up = (e: any) => {
            var no = parseInt(e.currentTarget.getAttribute("data-no"));
            this.item.splice(no-1, 2, this.item[no], this.item[no-1]);
            this.menuChange(no, -1);
        }
        // 下ボタン
        this.down = (e: any) => {
            // メニュー入れ替え
            var no = parseInt(e.currentTarget.getAttribute("data-no"));
            this.item.splice(no, 2, this.item[no+1], this.item[no]);
            this.menuChange(no, 1);
        }
        this.menuChange = (no: number, n: number) => {
            // メニュー入れ替え
            this.item[no].no = no
            this.item[no + n].no = no + n;
            
            // ソート順入れ替え
            var s = this.item[no].sort_no;
            this.item[no].sort_no = this.item[no + n].sort_no;
            this.item[no + n].sort_no = s;
            
            // データ保存
            var self = this;
            fetch('/treco/write_menuSort', {
                method: 'POST'
                , body: JSON.stringify({
                    menuCd1: this.item[no].menu_cd
                    , menuCd2: this.item[no + n].menu_cd
                    , sortNo1: this.item[no].sort_no
                    , sortNo2: this.item[no + n].sort_no
                })
                , headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                }
                , credentials: "include"
            }).then(function(data) {
                self.update();
            });
        };
        
        
        // 戻るボタン
        this.back = () => {
            var r = this.parent.route.create();
            r('menumain');
            this.update();
        }
        
        // 追加ボタン
        this.add = () => {
            var r = this.parent.route.create();
            r('menuedit/-1');
            this.update();
        }
        
