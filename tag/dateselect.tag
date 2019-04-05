
date-select
    select(ref="year", onchange="{change_ym}")
        option(each="{years}", value="{year}", selected="{year==parseInt(date/10000)}") {year}
    select(ref="month", onchange="{change_ym}")
        option(each="{months}", value="{month}", selected="{month==parseInt(date/100)%100}") {month}
    select(ref="day", onchange="{change_d}")
        option(each="{days}", value="{day}", selected="{day==date%100}") {day}
        
        
    style(type="stylus").
        select
            font-size 1.25em
            
            
    script().
        var d = new Date();
        this.years = []
        this.months = [];
        this.setDay = d.getDate();
        this.y = d.getFullYear();
        this.m = (d.getMonth() + 1);
        this.d = d.getDate();
        this.date = this.y * 10000 + this.m * 100 + this.d;
        
        // 年月のリスト作成
        for(var i = this.y - 5; i <= this.y + 5; i++) {
            this.years.push({year: i});
        }
        for(var i = 1; i <= 12; i++) {
            this.months.push({month: i});
        }
        
        // 年月更新時の処理（日を再取得する）
        this.change_ym = () => {
            this.y = parseInt(this.refs.year.value);
            this.m = parseInt(this.refs.month.value);
            this.setDays(this.y, this.m);
            this.date = this.y * 10000 + this.m * 100 + this.d;
            this.trigger('date');
        }
        
        // 日更新時の処理（内部値を取得する）
        this.change_d = () => {
            this.d = parseInt(this.refs.day.value);
            this.date = this.y * 10000 + this.m * 100 + this.d;
            this.trigger('date');
        }
        
        // 日付リスト作成
        this.setDays = (year: number, month: number) => {
            var d = (new Date(year, month, 0)).getDate();
            if (d < this.d) {
                this.d = d;
            }
            this.days = [];
            for(var i = 1; i <= d; i++) {
                this.days.push({day: i});
            }
            this.date = this.y * 10000 + this.m * 100 + this.d;
        }
        // 日付リスト初期設定
        this.setDays(this.y, this.m);
        
        // 現在の値を取得する
        this.on('mount', () => {
            this.y = parseInt(this.refs.year.value);
            this.m = parseInt(this.refs.month.value);
            this.d = parseInt(this.refs.day.value);
            this.date = this.y * 10000 + this.m * 100 + this.d;
        });
        
        
        
        

