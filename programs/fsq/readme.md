# expirate_licenses_notifier.pl
- 程序目的：

  这个脚本用来自动向许可证快要到期（30天内）的厂商发提醒邮件。我们是根据表NSACCU.HOLDING_LICENSES_NOTICE.flag字段来确定是否要发送提醒邮件的，flag=0表示没有投递，1-表示已经投递，-1表示表NSACCU.HOLDING_LICENSES_NOTICE.contract_email里的邮箱地址有问题，无法投递。

- 重跑方法：
> cd e:\apps\programs\fsq\expirate_licenses_notifier.pl

- log文件所在地：
> e:\applogs\fsq\yyyymmdd

- 如果执行失败：
 万一发送邮件失败，程序会通知相关人员。相关人员的邮箱设置在：
``` e:\apps\config\impsp_config.pl``` 文件中的```$notify_list```变量所定义的匿名字串数组中。只要把邮箱地址一行行写入即可，以回车分隔:
```perl
$notify_list = [ qw(
    zhangpeng@e-future.com.cn
    john.doe@anywhere.go
)];
```

 可以根据邮件内容及看log文件查看问题出在哪里。

 另外，程序是根据表NSACCU.HOLDING_LICENSES_NOTICE.contact_email字段来确定厂商的邮箱地址的，如果这个字段内容没有‘@’符号，我们将认为这个邮箱地址是无效的，会将此条记录的flag设为-1,表示这个厂商无法投递。

  
