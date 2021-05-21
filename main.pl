#!/usr/bin/perl -w
#重写年月日时干支程序
#paul<sinbud2004@gmail.com>
#V20210514

use v5.10;

#原始十天干十二地支
my @TG = qw/ 甲 乙 丙 丁 戊 己 庚 辛 壬 癸 /;
my @DZ = qw/ 子 丑 寅 卯 辰 巳 午 未 申 酉 戌 亥 /;

#处理成最小公倍数60形式的列表
push @TG_60,@TG,@TG,@TG,@TG,@TG,@TG;
push @DZ_60,@DZ,@DZ,@DZ,@DZ,@DZ;

#处理成最小序号为1形式的列表
my @_TG_60 = @TG_60;
my @_DZ_60 = @DZ_60;
unshift @_TG_60,"空";
unshift @_DZ_60,"空";

#增加一组，最小序号为1形式的干支一组
my @_TG = @TG;
my @_DZ = @DZ;
unshift @_TG,"空";
unshift @_DZ,"空";

###===================================================
###以下程序段可计算公元前后任意年份的干支
###输入：1904或236BC,输出为干支，附加_xx_60列表内的序号
sub year_gz{
  my $year = $_[0]; #设置一个年份变量存储输入的年份字符串

  my $bc_state = ($year =~ /BC/i)?1:0;   #公元状态标志1公元前 0公元后

  $bc_state && ($year =~ s/BC//i);  #判断是公元前，则去掉bc字符

  #计算天干标识,使用新公式计算
  #公元前：年干=8-N(N<8)或8-N+10,N=年%10
  #公元后：年干=N-3(N>3)或N-3+10,N=年%10
   if ($bc_state){
     $tg_base = ($year%10<8)?(8-$year%10):(18-$year%10);
   } else {
     $tg_base =($year%10>3)?($year%10-3):($year%10+7);
   }

  #计算地支标识,使用新公式计算
  #公元前：年支=10-N(N<10)或10-N+12,N=年%12
  #公元后：年支=N-3(N>3)或N-3+12,N=年%12
   if ($bc_state) {
     $dz_base = ($year%12<10)?(10-$year%12):(22-$year%12);
   } else {
     $dz_base = ($year%12>3)?($year%12-3):($year%12+9);
   }
 
  #取出天干和地支
   push my @result,($_TG_60[$tg_base],$_DZ_60[$dz_base],$tg_base,$dz_base);  
  #注：使用#_DZ[标识号]来取出，压入返回值中
  
  return @result;
}

###================================================
#下面一段程序用于计算农历时辰的干支,参数为日干号，1-12时辰
sub time_gz{
   #求时干的列表
   my $day_tg_num = $_[0];  #日干号为第一个传入的参数
   my $time_num = $_[1]; #农历时辰为第二个传入的参数
  
   #传入的日干号转换过程：由于16|27|38|49|510一致，故
     $day_tg_num = ($day_tg_num > 5) ? ($day_tg_num-5):($day_tg_num);
   #求出日干所对应该的子时的天干号13579，推导2×N-1
     my $zhishi_tg_num = 2*$day_tg_num - 1;

   #这样时辰的干支都算出来了,注：这种编号形式，子时加上一个时辰再减一才是
     push my @result,($_TG_60[$zhishi_tg_num+$time_num-1],$_DZ[$time_num],
                       $zhishi_tg_num+$time_num-1,$time_num);
     return @result;
}

###================================================
#下面一段程序用于计算农历月份的干支,参数为年干号，月份
sub month_gz{
   my @_month_DZ = qw/ 空 寅 卯 辰 巳 午 未 申 酉 戌 亥 子 丑 /;#月支的列表
   
   #求月干的列表
   my $year_tg_num = $_[0];  #年干号为第一个传入的参数
   my $month_num = $_[1]; #农历月份为第二个传入的参数
   
   #传入的年干号转换过程：由于16|27|38|49|510一致，故
    $year_tg_num = ($year_tg_num > 5)? ($year_tg_num-5):$year_tg_num;

   #求出年干对应该的农历一月份的天干号
     my $jan_tg_num = 2 * $year_tg_num +1;
   
   #这样干支都算出来了
     push my @result,($_TG_60[$jan_tg_num+$month_num-1],$_month_DZ[$month_num],
                       $jan_tg_num+$month_num-1,$month_num+2);
     return @result;
}

#=====================================================
#测试公元前2697年子月子日
#@test_year = year_gz("2697bc");
#@test_time = time_gz(1,1);
#@test_month = month_gz(1,11);
#say "@test_year";
#say "@test_month";
#say "@test_time";

#===============求日支程序===========================

my @table_year = qw/ 31 36 42 47 52 57 3 8 13 18 24 29 34 39 45 50 55 0 6 11 16 21 27 32 37 42 48 53 58 3 9 14 19 24 30 35 40 45 51 56 1 6 12 17 22 27 33 38 43 48 54 59 4 9 15 20 25 30 36 41 46 51 57 2 7 12 18 23 28 33 39 44 49 54 0 5 10 15 21 26 /;

my @table_month = qw/ null 6 37 0 31 1 32 2 33 4 34 5 35 /;

sub day_gz{  #三个参数，为阳历，如1984 6 18
    my $year=$_[0];
    my $month=$_[1];
    my $day=$_[2];

    my $bc_state = ($year =~ /BC/i)?1:0;   #公元状态标志1公元前 0公元后
    $bc_state && ($year =~ s/BC//i);  #判断是公元前，则去掉bc字符
 
    #1-2月份单独处理
    ($month > 2) || ($year -= 1);

    $year_dist_1950_num = ($bc_state)?($year-1-1950)%80:($year-1950)%80;
    #上行计算年份距1950的距离，模上80,取得年数的序号。
    #处理一下负值
    $year_dist_1950_num =($year_dist_1950_num >= 0)?$year_dist_1950_num:
                                   $year_dist_1950_num + 80;

    #取出年数
    $year_num = $table_year[$year_dist_1950_num];
    #取出月数
    $month_num = $table_month[$month];
 
    #处理一下干支号
    $day_gz_num = $year_num + $month_num + $day;
    $day_gz_num = ($day_gz_num > 60)?($day_gz_num-60):$day_gz_num;

    #返回的日干号整理
    my $day_tg_num_tide = $day_gz_num%10;
    push @result,$_TG_60[$day_gz_num],$_DZ_60[$day_gz_num],$day_tg_num_tide,$day_gz_num;
    return @result;
}   

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#这一部分不受年份限制，但是需要知到农历年月日时，公历年月日才能使用，不受限的公农历转换尚未实现，

print "输入年：";
chomp(my $sun_year = <STDIN>);
print "输入公历月：";
chomp(my $sun_month = <STDIN>);
print "输入公历日：";
chomp(my $sun_day = <STDIN>);
print "输入农历月：";
chomp(my $lunar_month = <STDIN>);
print "输入农历日：";
chomp(my $lunar_day = <STDIN>);
print "输入时辰（1-12）：";
chomp(my $lunar_time = <STDIN>);

my @year_gz_fetch = &year_gz($sun_year);
my @month_gz_fetch = &month_gz($year_gz_fetch[2],$lunar_month);
my @day_gz_fetch = &day_gz($sun_year,$sun_month,$sun_day);
my @time_gz_fetch = &time_gz($day_gz_fetch[2],$lunar_time);

printf "%50s\n","+" x 50;
printf "\t%s\t%s\t%s\t%s\n","时","日","月","年";
printf "%50s\n","+" x 50;
printf "\t%s\t%s\t%s\t%s\n",$time_gz_fetch[0],$day_gz_fetch[0],$month_gz_fetch[0],$year_gz_fetch[0];
printf "\t%s\t%s\t%s\t%s\n",$time_gz_fetch[1],$day_gz_fetch[1],$month_gz_fetch[1],$year_gz_fetch[1];
printf "%50s\n","+" x 50;

#==========================================================
=pod
#重写交互部分，这一部分引用了网上的cal.pl源程序，直接农历公历转换，但年份限制1900-2049
print "农历日期请选1,公历日期请选2：";
chomp(my $choice = <STDIN>);
print "年月日值(例19000101):";
chomp(my $date = <STDIN>);
print "时辰(1-12时辰)：";
chomp(my $shichen = <STDIN>);

if ($choice == 1) {
  my @sun_date_list = `./lunar_cal.pl -l $date`;
  my ($sun_year,$sun_month,$sun_day) = ($sun_date_list[0] =~ /(\d+)年(\d+)月(\d+)号/);
  print "公历$sun_year年$sun_month月$sun_day日\n";
  
  my ($lunar_month,$lunar_day) = ($date =~ /.{4}(.{2})(.{2})/);
  ## print "$lunar_month,$lunar_day\n";
  $lunar_month = int($lunar_month);
  $lunar_day = int($lunar_day);
  print "农历$sun_year年$lunar_month月$lunar_day日\n";

  my @year_gz_fetch = &year_gz($sun_year);
  my @month_gz_fetch = &month_gz($year_gz_fetch[2],$lunar_month);
  my @day_gz_fetch = &day_gz($sun_year,$sun_month,$sun_day);
  my @time_gz_fetch = &time_gz($day_gz_fetch[2],$shichen);

 printf "%50s\n","+" x 50;
 printf "\t%s\t%s\t%s\t%s\n","时","日","月","年";
 printf "%50s\n","+" x 50;
 printf "\t%s\t%s\t%s\t%s\n",$time_gz_fetch[0],$day_gz_fetch[0],$month_gz_fetch[0],$year_gz_fetch[0];
 printf "\t%s\t%s\t%s\t%s\n",$time_gz_fetch[1],$day_gz_fetch[1],$month_gz_fetch[1],$year_gz_fetch[1];
 printf "%50s\n","+" x 50;


} elsif ($choice == 2) {
  my @lunar_date_list = `./lunar_cal.pl -s $date`;
  print @lunar_date_list;
  print "本程序只能以农历计算，查询完毕请重新运行本程序！\n";
  
} else {}
=cut
