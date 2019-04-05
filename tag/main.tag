main
    //- アプリタイトル
    .app-title
        div.title
            span.icon-trophy
            span とれこ
            span.icon-exclamation
            span.app-sub-title Trainig Recorder Tool
        div.button(show="{isLogin}")
            button(onclick="{logout}")
                span.icon-sign-out
        
    //- アプリ本体
    .app-body
        login(if="{page=='login'}")
        menumain(if="{page=='menumain'}")
        workout(if="{page=='workout'}")
        menulist(if="{page=='menulist'}")
        menuedit(if="{page=='menuedit'}")
        historylist(if="{page=='historylist'}")
        history1(if="{page=='history1'}")
        history2(if="{page=='history2'}")
            
    
    style(type="stylus").
        $teme-color = #8b9a2f
        $font-color = #4c4c4c
        
        // アプリタイトル
        .app-title
            // 両端揃え用の設定
            text-align right
            position relative
            box-sizing border-box
            width auto
            color white
            background-color $teme-color
            padding 0.5em 0.5em
            clearfix()
            // タイトル本体
            .title
                font-size 1.75em
                font-weight bold
                text-shadow -1px -1px 0 $font-color
                float left
                /*.icon-trophy
                    margin-right 0.25em*/
                .icon-exclamation
                    position relative
                    top 2px
                    left 4px
                .app-sub-title
                    content "Trainig Recorder Tool"
                    position relative
                    left 1em
                    font-size 0.4em
                    font-weight normal
                    text-shadow none
                    color white 
            // ログアウトボタン
            .button
                button
                    font-size 1em
                    color white
                    border 1px solid white
                    border-radius 5px
                    background-color $teme-color
                    padding 0.4em 1em
                    &:hover
                        color $teme-color
                        background-color white
                    &:active
                        color white
                        background-color darken($teme-color, 20%)
                        
        // アプリ本体
        .app-body
            box-sizing border-box
            width 100%
            padding 1em 0.5em 5em 0.5em
            
            
    script.
        interface Window {
            route: any;
        }
        this.route = window.route;
        this.route = this.opts.route;
        this.page = 'login';
        this.isLogin = false;
        
        var d = new Date();
        this.date = d.getFullYear() * 10000 + (d.getMonth() + 1) * 100 + d.getDate();
        
        var movePage = (name: string, login: boolean) => {
            this.page = name;
            this.isLogin = login;
            this.update();
        }
        
        // ルーティング設定
        var r = this.route.create();
        r('login', () => {
            movePage('login', false);
        });
        r('menumain', () => {
            movePage('menumain', true);
        });
        r('workout/*', (cd: string) => {
            this.menuCd = cd;
            movePage('workout', true);
        });
        r('menulist', () => {
            movePage('menulist', true);
        });
        r('menuedit/*', (cd: string) => {
            this.menuCd = cd;
            movePage('menuedit', true);
        });
        r('historylist', () => {
            movePage('historylist', true);
        });
        r('history1/*', (cd: string) => {
            this.menuCd = cd;
            movePage('history1', true);
        });
        r('history2', () => {
            movePage('history2', true);
        });
        
        // ログアウト処理
        this.logout = () => {
            var res = confirm('ログアウトします。よろしいですか？');
            if (res) {
                fetch('/treco/read_logout');
                this.isLogin = false;
                var r = this.opts.route.create();
                r('login');
                this.update();
            }
        }
        
        // ログインチェック
        this.checkLogin = () => {
            var self = this;
            fetch('/treco/read_isLogin', {credentials: "include"})
            .then(function(data) {
                return data.json();
            }).then(function(json) {
                if (json.isLogin !== true) {
                    alert('セッションが切断されました。再度ログインしてください。');
                    self.isLogin = false;
                    var r = self.opts.route.create();
                    r('login');
                    self.update();
                }
            });
        }
        
        
        