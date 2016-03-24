# email_job.pl

- 程序目的

> 这个程序是给NSA各脚本共用的，专门为Apps目录里的脚本发送工作邮件的程序。
> 这个程序将会被每十五分钟被调用，它会到指定目录搜索指定文件格式的文件，然后将解析这些文件，并按文件内说明的地址、标题、内容和附件，将邮件发出去。

- 程序约定
  符合以下条件的文件会被这个程序找到并发出去：
  1. 这个文件放在e:\applogs\email\yyyymmdd目录。（实际上是e:\apps\config\site_config\emailDir指定的目录。）
  2. 这个文件名以email开头的，以txt为后缀的文件。如：

  > email_impsp_20160324_160135.txt

  3. 文件内容如下：
  > TO:|{以竖线分隔的邮箱列表，用来放要投递的邮箱地址}
  >
  > SUBJECT:|{邮件标题}
  >
  > ATTACH:|{附件路径的绝对地址}
  >
  > =============================================
  >
  > 信的内容
  >

  4. 例子：
  
  ```
  TO|zhangpeng@e-future.com.cn
  SUBJECT|nsa20.impsp has Error!
  ATTACH|e:\applogs\nsa20\20160323\nsa20.impsp20160324_060008.log
  ===============================================
  e:\appdata\nsa20\in\20160323\PSPMEMD_20160323.csv can not be found!

  ```
  
  
