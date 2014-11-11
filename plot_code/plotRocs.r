#define a color list to differentiate lines
colorList <- c(1,2,3,4,5,6,7,8)
lineTypeList <- c(1,2,3,4,5,6)

# This functions plots a list of roc curves with x and y limits
plotRocs <- function(rocList, names, xlimits, ylimits){

	plot(rocList[[1]],col=colorList[[1]],xlim=xlimits,ylim=ylimits)
	for(i in 2:length(rocList)){
		plot(rocList[[i]],add=TRUE,col=colorList[[(i %% length(colorList)) + 1]], type="l", lty=lineTypeList[[(floor(i/length(colorList)) %% length(lineTypeList)) + 1]])
	}
	legend("center",names,col=colorList,lty=1:1)
}



plotDists <- function(distList,names,titles,bins)
{
  #get the histograms of the distributions
  hists <- vector("list",length(distList))
  for(i in 1:length(distList)){
    hists[i] <- list(hist(distList[[i]],br=bins,plot=FALSE));
    hists[[i]]$counts <- hists[[i]]$counts / length(distList[[i]]);
  }

  #get the max value of a histograms
  maxCount <- 0
  for(i in 1:length(hists)){
    if(max(hists[[i]]$counts) > maxCount){
      maxCount <- max(hists[[i]]$counts);
    }
  }

  minCount <- 1
  for(i in 1:length(hists)){
    if(min(hists[[i]]$counts[hists[[i]]$counts > 0]) < minCount){
      minCount <- min(hists[[i]]$counts[hists[[i]]$counts > 0])
    }
  }

  # determine the midpoint of each bin
	binMids <- c();
  for( i in 1:length(bins)-1 )
  {
    binMin <- bins[i];
    binMax <- bins[i+1];
    binMids[i] = (binMin+binMax)/2;
  }

	#plot the distributions
	colorIndex <- 1
	typeIndex <- 1
  legendLty <- c()
  legendCol <- c()
  first_plot <- 1;

  for (i in 1:length(hists))      # for each hist
  {
    legendLty <- c(legendLty,lineTypeList[[typeIndex]])
    legendCol <- c(legendCol,colorList[[colorIndex]])

    this_hist <- hists[[i]];

    need_plotting <- 0;
    first <- 1;
    second <- 2;
    start_index <- 1;
    end_index <-1;
    
    while( second <= length(binMids))
    {
      if ( this_hist$counts[first] == 0 && this_hist$counts[second] == 0 )
      {
      }
      else if ( this_hist$counts[first] == 0 && this_hist$counts[second] > 0 )
      {
        start_index <- first; 
        end_index <- second; 
        if ( second == length(binMids) )
        {
          need_plotting <- 1;
        }
      }
      else if (this_hist$counts[first] > 0 && this_hist$counts[second] > 0 )
      {
        end_index <- second;
        if ( second == length(binMids) )
        {
          need_plotting <- 1;
        }
      }
      else if (this_hist$counts[first] > 0 && this_hist$counts[second] == 0 )
      {
        end_index  <- second;
        need_plotting <- 1;
      }

      if ( need_plotting == 1 ) 
      {
        # plot...
        xcoords <- binMids[start_index:end_index];
        ycoords <- this_hist$counts[start_index:end_index];

        if ( first_plot == 1 )
        {
	        plot(xcoords,ycoords,col=colorList[[colorIndex]],xlab=titles[[2]],ylab=titles[[3]],main=titles[[1]],type="l",xlim=c(min(bins),max(bins)),ylim=c(0,1.0),lty=lineTypeList[[typeIndex]], cex=1.5);
          first_plot <- 0;
        }
        else
        {
          lines(xcoords,ycoords,col=colorList[[colorIndex]],type="l",lty=lineTypeList[[typeIndex]]);
        }

        need_plotting <- 0;
        start_index <- second;
        end_index <- second;
      }

      first <- first+1;
      second <- second+1;
    }

	  colorIndex <- incrementIndex(colorIndex,length(colorList))
  	if(colorIndex == 1){
	  	typeIndex <- incrementIndex(typeIndex, length(lineTypeList))
  	}
  }  

	# THIS IS WHERE I DRAW THE LEGEND
  # top left:	
  legend(min(binMids),maxCount,c(names),col=legendCol,lty=legendLty)
	# Or, for example, at x=0.27, y = top of graph.   Note that this is where the top left corner of the legend should go.
  #legend(0.55,1.0,c(names),col=legendCol,lty=legendLty)
  #legend(100,1,c(names),col=legendCol,lty=legendLty)
}



#increment an index
incrementIndex <- function(index,indexSize){
	index <- (index + 1) %% (indexSize + 1)
	if(index == 0){
		index <- 1
	}
	return(index)
}

#this will split a histogram up removing the consecutive zero elements
removeZeros <- function(histObj){
	leftVal <- 0
	rightVal <- 0

	#sMode 0 is trying to find 0's
	#sMode 1 is tring to find non-0's
	sMode <- 0
	splits <- c()
	splitCount <- 0

	if(histObj$counts[[1]] == 0 && histObj$counts[[2]] == 0){
		sMode <- 1
	}
	else{
		splits <- c(0)
	}

	for(i in 1:length(histObj$counts)){
		if(i > 1){
			leftVal <- histObj$counts[[i-1]]
		}
		else{
			leftVal <- 0
		}
		if(i < length(histObj$counts)){
			rightVal <- histObj$counts[[i+1]]
		}	
		else{
			rightVal <- 0
		}

		if(sMode == 0){
			if(leftVal == 0 && rightVal == 0 && histObj$counts[[i]] == 0){
				splits <- c(splits,i-1)
				splitCount <- splitCount + 1
				sMode <- 1
			}
		}
		else{
			if(rightVal != 0){
				splits <- c(splits, i)
				sMode <- 0
			}
		}
	}
	
	newCounts <- 0
	newMids <- 0
	if(length(splits) %% 2 != 0){
		#the last split goes to the end 
		#there is actually one more split than the count implies
		newCounts <- vector("list",splitCount+1)
		newMids <- vector("list",splitCount+1)
	}
	else{
		newCounts <- vector("list",splitCount)
		newMids <- vector("list",splitCount)
	}	

	#print(length(splits))
	#print(splits[[1]])
	#print(splits[[2]])
	#split the vectors
	for(i in 1:splitCount){
    print('A')
    print(histObj$counts)
		newCounts[[i]] <- histObj$counts[splits[[2*(i-1)+1]]:splits[[2*(i-1)+2]]]
    print('B')
		newMids[[i]] <- histObj$mids[splits[[2*(i-1)+1]]:splits[[2*(i-1)+2]]]
  #  print('C')
	}
	if(length(newCounts) > splitCount){
    print('D')
		newCounts[[splitCount+1]] <- histObj$counts[splits[[splitCount+2]]:length(histObj$counts)]
    print('E')
		newMids[[splitCount+1]] <- histObj$mids[splits[[splitCount+2]]:length(histObj$counts)]
    print('F')
	}
	lst <- list(counts=newCounts,mids=newMids,size=length(newCounts))
	return(lst)
}
