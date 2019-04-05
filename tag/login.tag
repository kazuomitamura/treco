login
    div
        p
            input(type="text", ref="uid", placeholder="ユーザーID")
        p
            input(type="password", ref="pwd", placeholder="パスワード")
        p
            button.icon-sign-in(onclick="{login}") ログイン
            
    
    style(type="stylus").
        div
            text-align center
            padding-top 5em
        // 入力欄
        input
            padding 0.5em 1em
            width 15em
        // ログインボタン
        button
            margin-top 1em
            padding 1em
            width 15em
            color white
            background-color #8b9a2f
            border 1px solid #ddd5c2
            &:hover
                color #8b9a2f
                background-color white
            &:active
                color white
                background-color #8b9a2f
    
    
    script.
        this.login = () => {
            var uid = this.refs.uid.value;
            var pwd = this.refs.pwd.value;
            var self = this;
            fetch('/treco/read_login', {
                method: 'POST'
                , body: JSON.stringify({
                    uid: uid
                    , pwd: pwd
                })
                , headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                }
                , credentials: "include"
            }).then(function(data) {
                return data.json();
            }).then(function(json) {
                if (json.isLogin === true) {
                    // ユーザーIDとパスワードが一致すれば、メニュー画面に進む
                    var w: any = window;
                    var r = w.route.create();
                    r('menumain');
                    self.update();
                } else {
                    alert(json.msg);
                    self.refs.uid.focus();
                }
            });
        }
        
