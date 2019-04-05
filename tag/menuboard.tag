menuboard
    a.link-board-body.data-board-body(each="{item}", href="#{opts.page}/{menu_cd}") 
        span.link-board-title {menu_nm}
        span.link-board-icon.icon-chevron-right
    
    style(type="stylus").
        // リンクボード
        a.link-board-body
            display block
            padding 0.75em 1em !important
            text-decoration none
            // 両端揃え設定
            text-align right
            clearfix()
            .link-board-title
                float left
            .link-board-icon
                color #ddd5c2
                font-weight bold
            &:hover
                span:first-child
                    text-decoration underline
                
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
                self.item = json;
                self.update();
            });
        });