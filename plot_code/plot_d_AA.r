
source("../plotRocs.r")
library(ROCR);

##############################################################
# STRONG

Strong_MatchResults <- read.table("/afs/crc.nd.edu/user/a/asgroi/asgroi2/GBU/Partition2/STRONG_AA.txt", header=TRUE);
Strong_MatchScores <- (Strong_MatchResults$Score[Strong_MatchResults$Match == 1])
Strong_NonMatchScores <- (Strong_MatchResults$Score[Strong_MatchResults$Match == 0])

pdf("./Strong_AA.pdf")
distList <- list(Strong_MatchScores,Strong_NonMatchScores);
names <- list('Match','Non-Match');
titles <- list('Strong Partition Match and Non-Match Score Distributions', 'Similarity Score', 'Percentage of Comparisons');
bins <- pretty(range(Strong_MatchScores,Strong_NonMatchScores),40);
plotDists(distList,names,titles,bins);
dev.off();

max(Strong_NonMatchScores)
min(Strong_NonMatchScores)
mean(Strong_NonMatchScores)
sd(Strong_NonMatchScores)

##############################################################
# WEAK

Weak_MatchResults <- read.table("/afs/crc.nd.edu/user/a/asgroi/asgroi2/GBU/Partition2/WEAK_AA.txt", header=TRUE);
Weak_MatchScores <- (Weak_MatchResults$Score[Weak_MatchResults$Match == 1])
Weak_NonMatchScores <- (Weak_MatchResults$Score[Weak_MatchResults$Match == 0])

pdf("./Weak_AA.pdf")
distList <- list(Weak_MatchScores,Weak_NonMatchScores);
names <- list('Match','Non-Match');
titles <- list('Weak Partition Match and Non-Match Score Distributions', 'Similarity Score', 'Percentage of Comparisons');
bins <- pretty(range(Weak_MatchScores,Weak_NonMatchScores),40);
plotDists(distList,names,titles,bins);
dev.off();

max(Weak_NonMatchScores)
min(Weak_NonMatchScores)
mean(Weak_NonMatchScores)
sd(Weak_NonMatchScores)

##############################################################
# NEUTRAL

Neutral_MatchResults <- read.table("/afs/crc.nd.edu/user/a/asgroi/asgroi2/GBU/Partition2/NEUTRAL_AA.txt", header=TRUE);
Neutral_MatchScores <- (Neutral_MatchResults$Score[Neutral_MatchResults$Match == 1])
Neutral_NonMatchScores <- (Neutral_MatchResults$Score[Neutral_MatchResults$Match == 0])

pdf("./Neutral_AA.pdf")
distList <- list(Neutral_MatchScores,Neutral_NonMatchScores);
names <- list('Match','Non-Match');
titles <- list('Neutral Partition Match and Non-Match Score Distributions', 'Similarity Score', 'Percentage of Comparisons');
bins <- pretty(range(Neutral_MatchScores,Neutral_NonMatchScores),40);
plotDists(distList,names,titles,bins);
dev.off();

max(Neutral_NonMatchScores)
min(Neutral_NonMatchScores)
mean(Neutral_NonMatchScores)
sd(Neutral_NonMatchScores)



##############################################################
# ALL


#pdf("./All_AA.pdf")
#distList <- list(Neutral_MatchScores,Strong_NonMatchScores, Neutral_NonMatchScores, Weak_NonMatchScores);
#names <- list('Match [0.1, 0.99]','Strong NonMatches [0.40, 0.54]','Neutral NonMatches [0.32, 0.55]','Weak NonMatches[0.35, 0.99]');
#titles <- list('AA Match and NonMatch Score Distributions', 'Similarity Score', 'Percentage of Comparisons');
#bins <- pretty(range(Neutral_MatchScores,Strong_NonMatchScores,Neutral_NonMatchScores, Weak_NonMatchScores),40);
#plotDists(distList,names,titles,bins);
#dev.off();


##############################################################
# All ROCs for Partitions on one graph:

Strong_Scores <- (Strong_MatchResults$Score)
Strong_Match <- (Strong_MatchResults$Match)

Weak_Scores <- (Weak_MatchResults$Score)
Weak_Match <- (Weak_MatchResults$Match)

Neutral_Scores <- (Neutral_MatchResults$Score)
Neutral_Match <- (Neutral_MatchResults$Match)


#png("./partition_roc_AA_log.png")
Strong_pred <- prediction(Strong_Scores, Strong_Match);
Strong_perf <- performance(Strong_pred,"tnr","fnr");
Weak_pred <- prediction(Weak_Scores, Weak_Match);
Weak_perf <- performance(Weak_pred,"tnr","fnr");
Neutral_pred <- prediction(Neutral_Scores, Neutral_Match);
Neutral_perf <- performance(Neutral_pred,"tnr","fnr");


#pc<-c('red','forestgreen','blue');
#plot(Strong_perf@x.values[[1]],Strong_perf@y.values[[1]], xlab="False Accept Rate \n (Log Scale)",ylab="True Accept Rate", main="AA Partition Performance", col=pc[1],ylim=c(0,1.0),xlim=c(0.001,1.0), type="l", log="x");
#lines(Neutral_perf@x.values[[1]], Neutral_perf@y.values[[1]],lty=1,col=pc[2],log="x");
#lines(Weak_perf@x.values[[1]], Weak_perf@y.values[[1]],lty=1,col=pc[3], log="x");

#legend(0.001,0.8, c("Strong Partition", "Neutral Partition", "Weak Partition"), cex=1.0, col=pc, lty=1:1:1);
#dev.off();


png("similarity_FAR_AA.png")

plot(Strong_perf@alpha.values[[1]], Strong_perf@x.values[[1]], log="y", xlab="Similarity Cutoff Score", ylab="False Accept Rate", type="l", col="red", main="Similarity Cutoff Score compared to \n False Accept Rate on a log-scale (AA)")
 
lines(Neutral_perf@alpha.values[[1]], Neutral_perf@x.values[[1]], col="forestgreen", lty=1)
lines(Weak_perf@alpha.values[[1]], Weak_perf@x.values[[1]], col="blue", lty=1)

legend(0.6,0.01, c("Strong Partition", "Neutral Partition", "Weak Partition"), col=c("red","forestgreen","blue"), lty=1:1:1)
#legend(0.6,0.01, c("Strong Partition", "Neutral Partition"), col=c("black","forestgreen"), lty=1:1)

dev.off()


