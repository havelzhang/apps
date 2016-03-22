# load_impsp.pl
- 程序目的：

>  load pspmemd_yyyymmdd.csv接口。

- 重跑方法:

> cd e:\apps\programs\nsa20\
> load_impsp.pl \<yyyymmdd\>

- IMPSP 接口所在FTP站点及文件信息

>ftp site: csnp70102u.cdc.carrefour.com
>
>directory:/p4mdextraction
>
>file name:PSPMEMD_yyyymmdd.csv.gz

- loading log文件所在地：

> d:\applogs\nsa20\yyyymmdd
>
> 其中有sql loader的log文件:sqlldr_impsp_yyyymmdd_hhmiss.log
>
> 还有程序本身的log文件：nsa20.impspyyyymmdd_hhmiss.log

- 本地接口文件所在地：

> D:\appdata\nsa20\in\yyyymmdd

- 如果loading失败...

> 万一loading失败，程序会发邮件通知相关人员。相关人员的邮箱设置在:
>
> e:\apps\config\impsp_config.pl 文件中的$notify_list变量所定义的匿名字串数组中。只要把邮箱地址一行行写入即可，以回车分隔:
```perl
$notify_list = [ qw(
    zhangpeng@e-future.com.cn
    john.do@anywhere.go
)];
```

> 可以根据邮件内容及看log文件查看问题出在哪里。
  



