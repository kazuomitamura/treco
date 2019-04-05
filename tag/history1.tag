history1
    a(ref="h1top")
    div.pageanchor
        p(each="{item}")
            span.icon-angle-right
            a(href="#h1{setNm}") {setNm}
    .data-board(each="{item}")
        a(name="h1{setNm}")
        .data-board-title {setNm}
        .data-board-body 
            table
                tr(each="{item}")
                    th {date}
                    td {cnt1}
                    td {cnt2}
                    td {cnt3}
                    td {cnt4}
                    td {cnt5}
    
    a.movetop(onclick="{movetop}", href="#") 上へ
    
    //- ツールバー
    .toolbar
        button.icon-reply.left(onclick="{back}") 戻る
        
        
    style(type="stylus").
        .pageanchor
            margin-bottom 0.5em
            p
                margin-bottom 0.25em
        table
            border-collapse collapse
            td
                width 2.5em
                padding 0.5em 0.25em
                text-align center
            th
                padding 0.5em 0.5em
                background-color #f6f3e9
            td, th
                border 1px solid #ddd5c2
        .movetop
            fixed right 1em bottom 5em
                
                
    script.
        this.menuCd = parseInt(this.parent.menuCd);
        this.on('mount', () => {
            // 履歴データ取得
            var self = this;
            fetch('/treco/read_history1', {
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
                self.item = json;
                self.update();
            });
        });
        
        
        // 上へリンク
        this.movetop = () => {
            this.refs.h1top.scrollIntoView(true);
        };
        
        // 戻るボタン
        this.back = () => {
            var r = this.parent.route.create();
            r('historylist');
            this.update();
        }
