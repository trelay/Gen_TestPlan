#!/usr/bin/perl 

my $record = "record.txt";
my $path = shift;
my $TestSuit = &GetTestSuitName("$path/");
my $TestSuitPath = $path . $TestSuit . '/test_suite.sequence.properties';
my @allset = &GetSequence($TestSuitPath);
my @allcase = "";
my $set = "";
my $case = "";
my $type = "";
my $casetype = "";
my $testcasepath = "";
my $logpath = "";


foreach my $setline (@allset) {
   $set = (split(/=/,$setline))[0];   
   $type = (split(/=/,$setline))[1];   

   $testcasepath = $path . $TestSuit . "/".$type."_" . $set ."/test_set.sequence.properties";
   my $setpage = $path . $TestSuit ."/page.html";
   my $patt = $set.'\<\/a\>.*?\<b\>Passes\<\/b\>\<br\>(.*?s)\<\/center\>';
   my $testtime = &GetTime($setpage,$patt);
   &RecordInfo(sprintf("%-40s",$set).sprintf("%-15s",$type).$testtime."\n");

   @allcase =  &GetSequence($testcasepath);
   foreach $caseline (@allcase) {
     $case = (split(/=/,$caseline))[0];
     $casetype = (split(/=/,$caseline))[1];
     my $casepage = $path . $TestSuit . "/". $type. "_" . $set . "/page.html";
     my $patt = $case.'\<\/a\>.*?\<b\>Passes\<\/b\>\<br\>(.*?s)\<\/center\>';
     my $casetime = &GetTime($casepage,$patt);
     &RecordInfo(sprintf("%-40s",$case).sprintf("%-15s",$casetype).$casetime."\t");
     if ($casetype =~/action/){
       &RecordInfo("\n");
       next;
     }
     if ($case =~/(LED|DOWNLOAD)/) {
       &RecordInfo("\n");
       next;
     }
     $logpath = $path . $TestSuit . "/". $type. "_" . $set . "/".$casetype."_" . $case . "/";
     $lograw = $logpath . "log.raw";
     $summary = $logpath . "summary.html";
     if (-e $lograw ) {
       my $cmd = &GetCommand($lograw);  
       &RecordInfo($cmd."\n");
       #exit;
     } else {
       &RecordInfo("\n");
     }
   }
   &RecordInfo("\n\n");
   @allcase = "";
   
}

sub GetTime(){
  my $path = shift;
  my $pattern = shift;
  my $t = 0;
  open(HTML,"<$path") or die("Can't open the file $path");
  while(<HTML>){
    if(/$pattern/){
      $t = $1;
      return $t;
    }
  }

}

sub RecordInfo(){
  my $info = shift;
  open(OUTPUT,">>$record");
  print OUTPUT "$info";
  close(OUTPUT);  


}

sub GetTestSuitName(){
  my $path = shift;
  my $rc = `ls $path | grep test_suite`;
  chomp($rc);
  #print $rc;
  if ( $rc ne "" ) {
    return $rc;
  } else {
    return "Can't found test suit name";
  }
}

sub GetSequence(){
  my $path = shift;
  my @sequence ;
  open(CASE,"<$path") or die('Can not open the file $path');
  while(<CASE>){
    if(/=/){
      chomp();
      $line = $_;
      push(@sequence,$line);
    }
  }
  close(CASE);
  return @sequence;  

}

sub GetCommand(){
  my $path = shift;
  my $line = "";
  my $rc = "";
  open(CMDLINE,"<$path") or die("Can't open the file $path");
  while(<CMDLINE>){
    if(/Connection/){next;}
    next if /^s*$/;
    if(/(\#\s\w{2}|\#\s\/|\>\/|\>\w{3})/){
       chomp();
       $line = $_;
       $line =~s/[\r\n]$//g;
       $rc .= $line . '????';
    }
  }
  return $rc;
}
