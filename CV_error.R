x <- read.table("FILE.cv.error")
plot(x$V1, x$V2, type = "b", pch = 19, 
     col = "blue", xlab = "K", ylab = "CV error")
axis(side=1, at=seq(0, 20, by=1))
