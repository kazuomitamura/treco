menumain
    div.date
        span 日付：
        date-select(ref="date")
    
    .data-board
        .data-board-title
            span.title メニュー
            a.edit(href="#menulist") (編集)
        menuboard(ref="board", page="workout")
        
    //- ツールバー
    .toolbar
        button.icon-history(onclick="{historylist}") 履歴
        
        
    style(type="stylus").
        // トレーニング日
        .date
            font-size 1.2em
            margin 1em 0
            
        // タイトル
        .data-board-title
            text-align right
            .title
                float left
            .edit
                font-size 0.75em
                color #8b9a2f
                
    
    script.
        this.on('mount', () => {
            // ログインチェック
            this.parent.checkLogin();
            
            // 初期日付設定
            this.refs.date.date = this.parent.date;
            this.refs.date.update();
            
            // 日付変更時のイベント
            this.refs.date.on('date', () => {
                this.parent.date = this.refs.date.date;
            });
        });
        
        // 履歴ボタンクリック（履歴一覧画面を表示する）
        this.historylist = () => {
            var r = this.parent.route.create();
            r('historylist');
            this.update();
        }
        
        
        
    