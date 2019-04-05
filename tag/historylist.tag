historylist
    .data-board
        .data-board-title
            span.title トレーニング履歴
        menuboard(ref="board", page="history1")

    //- ツールバー
    .toolbar
        button.icon-reply.left(onclick="{back}") 戻る
        button.icon-star(onclick="{history2}") 全て
        
        
    script.
        // 戻るボタン
        this.back = () => {
            var r = this.parent.route.create();
            r('menumain');
            this.update();
        };
        
        // 全てボタン
        this.history2 = () => {
            var r = this.parent.route.create();
            r('history2');
            this.update();
        };
