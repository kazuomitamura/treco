test
    .data-board
        .data-board-title メニュー
        link-board(ref="board")
    
    script.
        this.on('mount', () => {
            var board = this.refs.board;
            board.item = [
                {title: 'メニュー１', id: 1}
                , {title: 'メニュー2', id: 2}
            ];
            board.update();
        });
        
        
        
    