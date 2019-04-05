import * as express from 'express';
import * as pg from 'pg';
import * as async from 'async';

var pgconf = {
    host: '192.168.172.150'
    , user: 'postgres'
    , password: 'postgres'
    , database: 'treco'
    , port: 5432
    , ssl: false
};


export class TrecoRouter {
    
    public router: express.Router;
    
    constructor () { 
        this.router = express.Router();
        this.app();
        
        // 読み込み処理登録
        this.read_login();
        this.read_isLogin();
        this.read_logout();
        this.read_menulist();
        this.read_workout();
        this.read_isWorkout();
        this.read_menuedit();
        this.read_history1();
        this.read_history2();
        
        // 書き込み処理登録
        this.write_removeWorkout();
        this.write_saveWorkout();
        this.write_menuSort();
        this.write_menuedit();
        this.write_removeMenu();
        
    }
    
    // アプリケーションの起動処理
    private app () {
        this.router.get('/app', (req: express.Request, res: express.Response, next: express.NextFunction) => {
            res.render('index', { title: 'とれこ！' });
        });
    }
    
    
    // ユーザー認証
    private read_login () {
        this.router.post('/read_login', (req: express.Request, res: express.Response, next: express.NextFunction) => {
            var uid = req.body.uid;
            var pwd = req.body.pwd;
            
            // DB接続
            var client = new pg.Client(pgconf);
            client.connect((err: any) => {
                if (err) console.log(err);
            });
            
            // DBからデータ取得してユーザー認証
            var r = res;
            var q = req;
            client.query('select cd, password from users where mail = $1', [uid])
                .then(res => {
                    client.end();
                    if (res.rows[0] === void 0 || res.rows[0].password !== pwd) {
                        q.session.isLogin = false;
                        q.session.userCd = null;
                        r.json({isLogin: false, msg: 'ユーザーIDかパスワードが正しくありません。'});
                    } else {
                        q.session.isLogin = true;
                        q.session.userCd = res.rows[0].cd;
                        r.json({isLogin: true});
                    }
                })
                .catch(err => {
                    client.end();
                    console.log(err);
                    q.session.isLogin = false;
                    q.session.userCd = null;
                    r.json({isLogin: false,msg: 'システムエラー'});
                });
        });
        
    };
    
    // ユーザー認証チェック
    private read_isLogin () { 
        this.router.get('/read_isLogin', (req: express.Request, res: express.Response, next: express.NextFunction) => {
            res.json({isLogin: req.session.isLogin});
        });
    }
    
    // ログアウト処理
    private read_logout () { 
        this.router.get('/read_logout', (req: express.Request, res: express.Response, next: express.NextFunction) => {
            req.session.isLogin = false;
            res.send(null);
        });
    }
    
    // メニュー一覧取得
    private read_menulist () {
        this.router.get('/read_menulist', (req: express.Request, res: express.Response, next: express.NextFunction) => {
            // DB接続
            var client = new pg.Client(pgconf);
            client.connect((err: any) => {
                if (err) console.log(err);
            });
            
            // DBからメニュー情報を取得して返却する
            var r = res;
            client.query('SELECT menu_cd, menu_nm, sort_no FROM menu WHERE user_cd = $1 ORDER BY sort_no DESC', [req.session.userCd])
            .then(res => {
                client.end();
                r.json(res.rows);
            })
            .catch(err => {
                client.end();
                console.log(err);
                r.json({});
            });
        });
    };
    
    // ワークアウトデータ取得
    private read_workout () {
        this.router.post('/read_workout', (req: express.Request, res: express.Response, next: express.NextFunction) => {
            // DB接続
            var client = new pg.Client(pgconf);
            client.connect((err: any) => {
                if (err) console.log(err);
            });
            
            // DBからワークアウトデータを取得して返却する
            var userCd = req.session.userCd;
            var menuCd = parseInt(req.body.menuCd);
            var date = parseInt(req.body.date);
            var result: any = [];
            var r = res;
            var q = 
                ' SELECT set1_nm, set1wu1_nm, set1wu1_cnt, set1wu2_nm, set1wu2_cnt, set1begin_cnt, set1begin_set' +
                '      , set2_nm, set2wu1_nm, set2wu1_cnt, set2wu2_nm, set2wu2_cnt, set2begin_cnt, set2begin_set' +
                '      , set3_nm, set3wu1_nm, set3wu1_cnt, set3wu2_nm, set3wu2_cnt, set3begin_cnt, set3begin_set' +
                '      , set4_nm, set4wu1_nm, set4wu1_cnt, set4wu2_nm, set4wu2_cnt, set4begin_cnt, set4begin_set' +
                '      , set5_nm, set5wu1_nm, set5wu1_cnt, set5wu2_nm, set5wu2_cnt, set5begin_cnt, set5begin_set' +
                '      , n.note, m.menu_nm' +
                ' FROM menu m LEFT JOIN note n ON m.user_cd = n.user_cd AND m.menu_cd = n.menu_cd and n.date1 = $3' +
                ' WHERE m.user_cd = $1' +
                ' AND m.menu_cd = $2'
            ;
            client.query(
                q, [userCd, menuCd, date]
            ).then(res => {
                // メニュー情報を構成する
                for (var i = 1; i <= 5; i++) {
                    if (res.rows[0]['set' + i + '_nm'] !== null && res.rows[0]['set' + i + '_nm'] !== '') {
                        result.push({});
                        result[i - 1].setNo   = i;
                        result[i - 1].setNm   = res.rows[0]['set' + i + '_nm'];
                        result[i - 1].wu1Nm   = res.rows[0]['set' + i + 'wu1_nm'];
                        result[i - 1].wu1Cnt  = res.rows[0]['set' + i + 'wu1_cnt'];
                        result[i - 1].wu2Nm   = res.rows[0]['set' + i + 'wu2_nm'];
                        result[i - 1].wu2Cnt  = res.rows[0]['set' + i + 'wu2_cnt'];
                        result[i - 1].goalCnt = res.rows[0]['set' + i + 'begin_cnt'];
                        result[i - 1].goalSet = res.rows[0]['set' + i + 'begin_set'];
                    }
                }
                result[0].menuNm = res.rows[0].menu_nm;
                result[0].note   = res.rows[0].note;
                
                // ワークアウトデータを取得する
                var q = 
                    ' SELECT set_no, cnt1, cnt2, cnt3, cnt4, cnt5, next_cnt, next_set' +
                    ' FROM workout' + 
                    ' WHERE user_cd = $1'+
                    ' AND menu_cd = $2' +
                    ' AND date1 = $3'
                ;
                return client.query(
                    q, [userCd, menuCd, date]
                );
            }).then (res => {
                // ワークアウトデータを構成する
                for (var i = 1; i <= result.length; i++) {
                    result[i - 1].count = []
                    for (var j = 1; j <= 5; j++) {
                        var cnt = null;
                        if (res.rows[i - 1] !== void 0) {
                            cnt = res.rows[i - 1]['cnt' + j];
                        }
                        result[i - 1].count.push({
                            cnt: cnt
                            , no: j
                            , setNo: i
                        });
                    }
                    if (res.rows[i - 1] !== void 0) {
                        result[i - 1].nextCnt = res.rows[i - 1].next_cnt;
                        result[i - 1].nextSet = res.rows[i - 1].next_set;
                    }
                }
                
                // 前回と前々回のデータを取得する
                var q = 
                    ' SELECT date1, set_no, cnt1, cnt2, cnt3, cnt4, cnt5, next_cnt, next_set' +
                    ' FROM workout' + 
                    ' WHERE user_cd = $1'+
                    ' AND menu_cd = $2' +
                    ' AND date1 < $3' +
                    ' ORDER BY date1 DESC, set_no' + 
                    ' LIMIT 20 OFFSET 0'
                ;
                return client.query(
                    q, [userCd, menuCd, date]
                );
            }).then (res => {
                // 前回と前々回のデータを構成する
                for (var i = 1; i <= result.length; i++) {
                    for (var j = 1; j <= 5; j++) {
                        // 目標取得
                        if (j === 1 && res.rows[i - 1] !== void 0) {
                            result[i - 1].goalCnt = res.rows[i - 1].next_cnt;
                            result[i - 1].goalSet = res.rows[i - 1].next_set;
                        }
                        // データ取得
                        for (var k = 0; k <= 1; k++) {
                            var cnt = null;
                            var d = res.rows[(i - 1) + k * result.length];
                            if (d !== void 0) cnt = d['cnt' + j];
                            result[i - 1].count[j - 1]['prev' + (k + 1)] = cnt;
                        }
                    }
                }
                
                client.end();
                r.json(result);
            }).catch(err => {
                client.end();
                console.log(err);
                r.json({});
            });
            
        });
    };

    // ワークアウトデータの存在確認
    private read_isWorkout () {
        this.router.post('/read_isWorkout', (req: express.Request, res: express.Response, next: express.NextFunction) => {
            // DB接続
            var client = new pg.Client(pgconf);
            client.connect((err: any) => {
                if (err) console.log(err);
            });
            
            // DBからデータ有無を取得して返却する
            var userCd = req.session.userCd;
            var menuCd = parseInt(req.body.menuCd);
            var date = parseInt(req.body.date);
            var r = res;
            client.query('SELECT set_no FROM workout WHERE user_cd = $1 AND menu_cd = $2 AND date1 = $3', [userCd, menuCd, date])
            .then(res => {
                client.end();
                r.json({
                    isWorkout: res.rows[0] !== void 0
                });
            })
            .catch(err => {
                client.end();
                console.log(err);
                r.json({});
            });
        });
    };
    
    // ワークアウトデータの削除
    private write_removeWorkout () {
        this.router.post('/write_removeWorkout', (req: express.Request, res: express.Response, next: express.NextFunction) => {
            // DB接続
            var client = new pg.Client(pgconf);
            client.connect((err: any) => {
                if (err) console.log(err);
            });
            
            // DBからデータを削除する
            var userCd = req.session.userCd;
            var menuCd = parseInt(req.body.menuCd);
            var date = parseInt(req.body.date);
            var r = res;
            client.query('DELETE FROM workout WHERE user_cd = $1 AND menu_cd = $2 AND date1 = $3', [userCd, menuCd, date])
            .then(res => {
                return client.query('DELETE FROM note WHERE user_cd = $1 AND menu_cd = $2 AND date1 = $3', [userCd, menuCd, date])
            }).then(res => {
                client.end();
                r.json({});
            }).catch(err => {
                client.end();
                console.log(err);
                r.json({});
            });
        });
    };
    
    // ワークアウトデータの保存
    private write_saveWorkout () {
        this.router.post('/write_saveWorkout', (req: express.Request, res: express.Response, next: express.NextFunction) => {
            // DB接続
            var client = new pg.Client(pgconf);
            client.connect((err: any) => {
                if (err) console.log(err);
            });
            
            // DBにデータを保存する
            var userCd = req.session.userCd;
            var menuCd = parseInt(req.body.menuCd);
            var date = parseInt(req.body.date);
            var r = res;
            var q = 
                ' INSERT INTO workout (' +
                '   user_cd, menu_cd, date1, set_no, cnt1, cnt2, cnt3, cnt4, cnt5, next_cnt, next_set' +
                ' ) VALUES (' +
                '   $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11' +
                ' )'
            ;
            async.each(req.body.set, (set, next) => {
                client.query(q, [
                    userCd, menuCd, date
                    , set.setNo
                    , set.cnt1
                    , set.cnt2
                    , set.cnt3
                    , set.cnt4
                    , set.cnt5
                    , set.nextCnt
                    , set.nextSet
                ]).then(res => {
                    next();
                })
                .catch(err => {
                    client.end();
                    console.log(err);
                    r.json({result: false});
                    return;
                });
    
            }, () => {
                client.query('INSERT INTO note (user_cd, menu_cd, date1, note) VALUES ($1, $2, $3, $4)', [
                    userCd, menuCd, date, req.body.note
                ]).then(() => {
                    client.end();
                    r.json({result: true});
                })
            });
        });
    };
    
    // メニュー並び順保存
    private write_menuSort () {
        this.router.post('/write_menuSort', (req: express.Request, res: express.Response, next: express.NextFunction) => {
            // DB接続
            var client = new pg.Client(pgconf);
            client.connect((err: any) => {
                if (err) console.log(err);
            });
            
            // DBからメニュー情報を取得して返却する
            var userCd = req.session.userCd;
            var menuCd1 = parseInt(req.body.menuCd1);
            var menuCd2 = parseInt(req.body.menuCd2);
            var sortNo1 = parseInt(req.body.sortNo1);
            var sortNo2 = parseInt(req.body.sortNo2);
            var r = res;
            var q = 'UPDATE menu SET sort_no = $1 WHERE user_cd = $2 AND menu_cd = $3';
            client.query(q, [sortNo1, userCd, menuCd1])
            .then(res => {
                return client.query(q, [sortNo2, userCd, menuCd2]);
            })
            .then(res => {
                client.end();
                r.json(res.rows);
            })
            .catch(err => {
                client.end();
                console.log(err);
                r.json({});
            });
        });
    };
    
    // 編集用メニュー詳細取得
    private read_menuedit () {
        this.router.post('/read_menuedit', (req: express.Request, res: express.Response, next: express.NextFunction) => {
            // DB接続
            var client = new pg.Client(pgconf);
            client.connect((err: any) => {
                if (err) console.log(err);
            });
            
            // DBからメニューデータを取得して返却する
            var userCd = req.session.userCd;
            var menuCd = parseInt(req.body.menuCd);
            var result: any = [];
            var r = res;
            var q = 
                ' SELECT set1_nm, set1wu1_nm, set1wu1_cnt, set1wu2_nm, set1wu2_cnt, set1begin_cnt, set1begin_set, set1last_cnt, set1last_set' +
                '      , set2_nm, set2wu1_nm, set2wu1_cnt, set2wu2_nm, set2wu2_cnt, set2begin_cnt, set2begin_set, set2last_cnt, set2last_set' +
                '      , set3_nm, set3wu1_nm, set3wu1_cnt, set3wu2_nm, set3wu2_cnt, set3begin_cnt, set3begin_set, set3last_cnt, set3last_set' +
                '      , set4_nm, set4wu1_nm, set4wu1_cnt, set4wu2_nm, set4wu2_cnt, set4begin_cnt, set4begin_set, set4last_cnt, set4last_set' +
                '      , set5_nm, set5wu1_nm, set5wu1_cnt, set5wu2_nm, set5wu2_cnt, set5begin_cnt, set5begin_set, set5last_cnt, set5last_set' +
                '      , menu_nm, sort_no' +
                ' FROM menu' +
                ' WHERE user_cd = $1' +
                ' AND menu_cd = $2'
            ;
            client.query(
                q, [userCd, menuCd]
            ).then(res => {
                client.end();
                r.json(res.rows[0]);
            }).catch(err => {
                client.end();
                console.log(err);
                r.json({});
            });
            
        });
    };
    
    // メニューデータの保存
    private write_menuedit () {
        this.router.post('/write_menuedit', (req: express.Request, res: express.Response, next: express.NextFunction) => {
            // DB接続
            var client = new pg.Client(pgconf);
            client.connect((err: any) => {
                if (err) console.log(err);
            });
            
            var userCd = req.session.userCd;
            var menuCd = parseInt(req.body.menuCd);
            var q = '';
            
            // DBからデータを削除する
            var r = res;
            q = 'DELETE FROM menu WHERE user_cd = $1 AND menu_cd = $2';
            client.query(
                q, [userCd, menuCd]
            ).then(res => {
                // DBにデータを保存する
                var q = '';
                if (menuCd !== -1) {
                    q = 'INSERT INTO menu (menu_cd, '
                } else {
                    q = 'INSERT INTO menu ('
                }
                q = q + 
                    '        user_cd, menu_nm, sort_no' +
                    '      , set1_nm, set1wu1_nm, set1wu1_cnt, set1wu2_nm, set1wu2_cnt, set1begin_cnt, set1begin_set, set1last_cnt, set1last_set' +
                    '      , set2_nm, set2wu1_nm, set2wu1_cnt, set2wu2_nm, set2wu2_cnt, set2begin_cnt, set2begin_set, set2last_cnt, set2last_set' +
                    '      , set3_nm, set3wu1_nm, set3wu1_cnt, set3wu2_nm, set3wu2_cnt, set3begin_cnt, set3begin_set, set3last_cnt, set3last_set' +
                    '      , set4_nm, set4wu1_nm, set4wu1_cnt, set4wu2_nm, set4wu2_cnt, set4begin_cnt, set4begin_set, set4last_cnt, set4last_set' +
                    '      , set5_nm, set5wu1_nm, set5wu1_cnt, set5wu2_nm, set5wu2_cnt, set5begin_cnt, set5begin_set, set5last_cnt, set5last_set' +
                    ' ) VALUES (' +
                    '    $1,  $2,  $3' + 
                    ' ,  $4,  $5,  $6,  $7,  $8,  $9, $10, $11, $12' + 
                    ' , $13, $14, $15, $16, $17, $18, $19, $20, $21' + 
                    ' , $22, $23, $24, $25, $26, $27, $28, $29, $30' + 
                    ' , $31, $32, $33, $34, $35, $36, $37, $38, $39' + 
                    ' , $40, $41, $42, $43, $44, $45, $46, $47, $48'
                if (menuCd !== -1) q = q + ', $49';
                q = q + ')';
                var b = req.body;
                var s = [
                    userCd, b.menu_nm, b.sort_no
                    , b.set1_nm, b.set1wu1_nm, b.set1wu1_cnt, b.set1wu2_nm, b.set1wu2_cnt, b.set1begin_cnt, b.set1begin_set, b.set1last_cnt, b.set1last_set
                    , b.set2_nm, b.set2wu1_nm, b.set2wu1_cnt, b.set2wu2_nm, b.set2wu2_cnt, b.set2begin_cnt, b.set2begin_set, b.set2last_cnt, b.set2last_set
                    , b.set3_nm, b.set3wu1_nm, b.set3wu1_cnt, b.set3wu2_nm, b.set3wu2_cnt, b.set3begin_cnt, b.set3begin_set, b.set3last_cnt, b.set3last_set
                    , b.set4_nm, b.set4wu1_nm, b.set4wu1_cnt, b.set4wu2_nm, b.set4wu2_cnt, b.set4begin_cnt, b.set4begin_set, b.set4last_cnt, b.set4last_set
                    , b.set5_nm, b.set5wu1_nm, b.set5wu1_cnt, b.set5wu2_nm, b.set5wu2_cnt, b.set5begin_cnt, b.set5begin_set, b.set5last_cnt, b.set5last_set
                ];
                if (menuCd !== -1) s.unshift(menuCd);
                return client.query(q, s);
            }).then(res => {
                // sort_noを更新する
                var q = 
                    ' UPDATE menu' +
                    ' SET sort_no = n' + 
                    ' FROM (SELECT MAX(sort_no) + 1 n FROM menu WHERE user_cd = $1) x'+
                    ' WHERE sort_no = -1 AND user_cd = $1'
                ;
                return client.query(q, [userCd]);
            }).then(res => {
                client.end();
                r.json({result: true});
            }).catch(err => {
                client.end();
                console.log(err);
                r.json({result: false});
                return;
            });
        });
    };
    
    // メニューデータの削除
    private write_removeMenu () {
        this.router.post('/write_removeMenu', (req: express.Request, res: express.Response, next: express.NextFunction) => {
            // DB接続
            var client = new pg.Client(pgconf);
            client.connect((err: any) => {
                if (err) console.log(err);
            });
            
            // DBからデータを削除する
            var userCd = req.session.userCd;
            var menuCd = parseInt(req.body.menuCd);
            var r = res;
            client.query('DELETE FROM menu WHERE user_cd = $1 AND menu_cd = $2', [userCd, menuCd])
            .then(res => {
                client.end();
                r.json({result: true});
            }).catch(err => {
                client.end();
                console.log(err);
                r.json({result: false});
            });
        });
    };
    
    // 履歴取得１
    private read_history1 () {
        this.router.post('/read_history1', (req: express.Request, res: express.Response, next: express.NextFunction) => {
            // DB接続
            var client = new pg.Client(pgconf);
            client.connect((err: any) => {
                if (err) console.log(err);
            });
            
            // DBからメニューデータを取得して返却する
            var userCd = req.session.userCd;
            var menuCd = parseInt(req.body.menuCd);
            var r = res;
            var q = 
                ' SELECT w.set_no, w.date1, w.cnt1, w.cnt2, w.cnt3, w.cnt4, w.cnt5' +
                ' , m.set1_nm, m.set2_nm, m.set3_nm, m.set4_nm, m.set5_nm' +
                ' FROM workout w' + 
                ' INNER JOIN menu m on w.user_cd = m.user_cd AND w.menu_cd = m.menu_cd' +
                ' WHERE w.user_cd = $1' +
                ' AND w.menu_cd = $2' + 
                ' ORDER BY w.set_no ASC, w.date1 DESC'
            ;
            client.query(
                q, [userCd, menuCd]
            ).then(res => {
                client.end();
                var result: any = [];
                if (res.rows.length >= 1) {
                    var item: any = [];
                    var setNo = parseInt(res.rows[0].set_no);
                    var setNm = res.rows[0]['set' + (res.rows[0].set_no+1) + '_nm'];
                    for (var i = 0; true; i++) {
                        if (i >= res.rows.length || setNo !== parseInt(res.rows[i].set_no)) {
                            result.push({
                                setNm: setNm
                                , setNo: setNo
                                , item: item
                            });
                            if (i >= res.rows.length) break;
                            setNo = parseInt(res.rows[i].set_no);
                            setNm = res.rows[i]['set' + (res.rows[i].set_no+1) + '_nm'];
                            item = [];
                        }
                        var d = res.rows[i].date1.toString();
                        item.push({
                            date: d.slice(0, 4) + '/' + d.slice(4, 6) + '/' + d.slice(-2)
                            , cnt1: res.rows[i].cnt1
                            , cnt2: res.rows[i].cnt2
                            , cnt3: res.rows[i].cnt3
                            , cnt4: res.rows[i].cnt4
                            , cnt5: res.rows[i].cnt5
                        });
                    }
                }
                r.json(result);
            }).catch(err => {
                client.end();
                console.log(err);
                r.json({});
            });
            
        });
    };
    
    // 履歴取得２
    private read_history2() {
        this.router.post('/read_history2', (req: express.Request, res: express.Response, next: express.NextFunction) => {
            // DB接続
            var client = new pg.Client(pgconf);
            client.connect((err: any) => {
                if (err) console.log(err);
            });
            
            // DBからメニューデータを取得して返却する
            var userCd = req.session.userCd;
            var r = res;
            var q = 
                ' SELECT w.date1, w.set_no, w.cnt1, w.cnt2, w.cnt3, w.cnt4, w.cnt5' +
                ' , m.set1_nm, m.set2_nm, m.set3_nm, m.set4_nm, m.set5_nm, n.note' +
                ' FROM workout w' + 
                ' INNER JOIN menu m on w.user_cd = m.user_cd AND w.menu_cd = m.menu_cd' +
                ' LEFT  JOIN note n on w.user_cd = n.user_cd AND w.menu_cd = n.menu_cd AND w.date1 = n.date1' +
                ' WHERE w.user_cd = $1' +
                ' ORDER BY w.date1 DESC, w.set_no ASC'
            ;
            client.query(
                q, [userCd]
            ).then(res => {
                client.end();
                var result: any = [];
                if (res.rows.length >= 1) {
                    var item: any = [];
                    var date = parseInt(res.rows[0].date1);
                    var note = res.rows[0].note;
                    for (var i = 0; true; i++) {
                        if (i >= res.rows.length || date !== parseInt(res.rows[i].date1)) {
                            var d = date.toString();
                            result.push({
                                date: d.slice(0, 4) + '/' + d.slice(4, 6) + '/' + d.slice(-2)
                                , item: item
                                , note: note
                            });
                            if (i >= res.rows.length) break;
                            date = parseInt(res.rows[i].date1);
                            note = res.rows[i].note;
                            item = [];
                        }
                        
                        item.push({
                            setNm: res.rows[i]['set' + (res.rows[i].set_no+1) + '_nm']
                            , cnt1: res.rows[i].cnt1
                            , cnt2: res.rows[i].cnt2
                            , cnt3: res.rows[i].cnt3
                            , cnt4: res.rows[i].cnt4
                            , cnt5: res.rows[i].cnt5
                        });
                    }
                }
                r.json(result);
            }).catch(err => {
                client.end();
                console.log(err);
                r.json({});
            });
            
        });
    };
    
    
    
    // メニュー一覧取得
    /*private read_menulist () {
        this.router.get('/read/menulist', (req: express.Request, res: express.Response, next: express.NextFunction) => {
            res.json({data: 'DATA'});
        });
    };*/
    
}