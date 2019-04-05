history2
    a(ref="h2top")
    .data-board(each="{item}")
        .data-board-title {date}
        .data-board-body(each="{item}")
            span(style='font-weight:bold; text-decoration: underline') {setNm}
            table
                tr
                    td {cnt1}
                    td {cnt2}
                    td {cnt3}
                    td {cnt4}
                    td {cnt5}
        .data-board-body(if="{note!='' && note !=null}")
            p.note {note}
            
    a.movetop(onclick="{movetop}", href="#") 上へ
    
    //- ツールバー
    .toolbar
        button.icon-reply.left(onclick="{back}") 戻る
        
        
    style(type="stylus").
        table
            margin-top 0.25em
            border-collapse collapse
            td
                width 4em
                padding 0.5em 0.25em
                text-align center
                border 1px solid #ddd5c2
        .movetop
            fixed right 1em bottom 5em
            
        .note
            width 100%
        
        
        
    script.
        this.item = [
            {
                date: '2018/07/13'
                , menu: [
                    {
                        title: 'インクライン・プッシュアップ'
                        , set1cnt: 30
                        , set2cnt: 30
                        , set3cnt: 30
                        , set4cnt: null
                        , set5cnt: null
                    }
                    , {
                        title: 'インクライン・プッシュアップ'
                        , set1cnt: 30
                        , set2cnt: 30
                        , set3cnt: 30
                        , set4cnt: null
                        , set5cnt: null
                    }
                ]
                , memo: 'ほげほげ'
            }
            , {
                date: '2018/07/10'
                , menu: [
                    {
                        title: 'インクライン・プッシュアップ'
                        , set1cnt: 30
                        , set2cnt: 30
                        , set3cnt: 30
                        , set4cnt: null
                        , set5cnt: null
                    }
                    , {
                        title: 'インクライン・プッシュアップ'
                        , set1cnt: 30
                        , set2cnt: 30
                        , set3cnt: 30
                        , set4cnt: null
                        , set5cnt: null
                    }
                ]
            }
        ];
        this.on('mount', () => {
            // 履歴データ取得
            var self = this;
            fetch('/treco/read_history2', {
                method: 'POST'
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
            this.refs.h2top.scrollIntoView(true);
        };
        
        // 戻るボタン
        this.back = () => {
            var r = this.parent.route.create();
            r('historylist');
            this.update();
        }
