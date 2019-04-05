import * as createError from 'http-errors';
import * as express from 'express';
import * as path from 'path';
import * as cookieParser from 'cookie-parser';
import * as session from 'express-session';
import * as logger from 'morgan';
import * as stylus from 'stylus';
import * as nib from 'nib';

import { TrecoRouter } from './routes/treco';
import * as usersRouter from './routes/users';

var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'pug');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(session({
  secret: 'treco_secret_key',
  resave: false,
  saveUninitialized: true,
  rolling: true,
  cookie:{
      httpOnly: true,
      secure: false, // HTTPSの場合のみcookieを使用する設定
      maxAge: 1000 * 60 * 60 * 24 * 30
  }
}));
app.use(stylus.middleware({
  src: path.join(__dirname, 'public')
  , compile: function compile(src, path) {
      return stylus(src)
          .set('filename', path)
          .set('compress', true)
          .use(nib())
          .import('nib');
    }
}));
app.use(express.static(path.join(__dirname, 'public')));

app.use('/treco', new TrecoRouter().router);
app.use('/users', usersRouter);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

module.exports = app;
