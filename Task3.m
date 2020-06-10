# Reading image
rgbImage = imread('../../Users/pc/Downloads/image1.bmp');
figure; imshow(rgbImage); title("Original");
blackChannel = zeros(size(rgbImage, 1), size(rgbImage, 2), 'uint8');

# getting the 3 channels and displaying each channel
redChannel = rgbImage(:,:,1);
channel = cat(3, redChannel, blackChannel, blackChannel);
figure; imshow(channel); title("Red Channel");
greenChannel = rgbImage(:,:,2);
channel = cat(3, blackChannel, greenChannel, blackChannel);
figure; imshow(channel); title("Green Channel");
blueChannel = rgbImage(:,:,3);
channel = cat(3, blackChannel, blackChannel, blueChannel);
figure; imshow(channel); title("Blue Channel");

# encoding loop for different values of m
for m = 1:4
  
  # initializing variables
  width = 1;
  redBlock = zeros(8,8);
  blueBlock = zeros(8,8);
  greenBlock = zeros(8,8);
  widthIndex = 1;
  heightIndex = 1;
  redCoefficients = zeros(135*m,240*m);
  blueCoefficients = zeros(135*m,240*m);
  greenCoefficients = zeros(135*m,240*m);
  
  # nested loop to cover all pixels
  while width < 1920
    height = 1;
    heightIndex = 1;
    while height < 1080
      
      # Getting our 8*8 block of each channel
      redBlock = redChannel(height:height+7,width:width+7);
      blueBlock = blueChannel(height:height+7,width:width+7);
      greenBlock = greenChannel(height:height+7,width:width+7);
      
      # apply 2D dct for each block
      redBlock = dct2(redBlock);
      blueBlock = dct2(blueBlock);
      greenBlock = dct2(greenBlock);
      
      # retaining m*m block of the coefficients
      redCoefficients(heightIndex:heightIndex+m-1,widthIndex:widthIndex+m-1) = redBlock(1:m,1:m);
      blueCoefficients(heightIndex:heightIndex+m-1,widthIndex:widthIndex+m-1) = blueBlock(1:m,1:m);
      greenCoefficients(heightIndex:heightIndex+m-1,widthIndex:widthIndex+m-1) = greenBlock(1:m,1:m);
      
      heightIndex = heightIndex + m;
      height = height + 8;
    endwhile
    widthIndex = widthIndex + m;
    width = width + 8;
  endwhile
  
  # casting coefficients to avoid overflow
  redCoefficients = cast(redCoefficients,'int16');
  blueCoefficients = cast(blueCoefficients,'int16');
  greenCoefficients = cast(greenCoefficients,'int16');
  
  # saving coefficients in separated files
  if m == 1
    save -binary M1 redCoefficients blueCoefficients greenCoefficients;
  elseif m == 2
    save -binary M2 redCoefficients blueCoefficients greenCoefficients;
  elseif m == 3
    save -binary M3 redCoefficients blueCoefficients greenCoefficients;
  elseif m == 4
    save -binary M4 redCoefficients blueCoefficients greenCoefficients;
  endif
endfor


# decoding loop for different values of m
redChannel = zeros(1080,1920);
blueChannel = zeros(1080,1920);
greenChannel = zeros(1080,1920);
for m = 1:4
  
  # uplaoding saved coefficients
  if (m == 1)
    load M1;
  elseif(m == 2)
    load M2;
  elseif(m == 3)
    load M3;
  elseif(m == 4)
    load M4;
  endif
  
  # initializing variables
  width = 1;
  widthIndex = 1;
  heightIndex = 1;
  widthLimit = 240*m;
  heightLimit = 135*m;
  while (width <= widthLimit)
    height = 1;
    heightIndex = 1;
    while (height <= heightLimit)
      # clearing our blocks to get the correct inverse dct
      redBlock = zeros(8,8);
      greenBlock = zeros(8,8);
      blueBlock = zeros(8,8);
      
      # getting m*m coefficients from saved matrix
      redBlock(1:m,1:m) = redCoefficients(height:height+m-1,width:width+m-1);
      blueBlock(1:m,1:m) = blueCoefficients(height:height+m-1,width:width+m-1);
      greenBlock(1:m,1:m) = greenCoefficients(height:height+m-1,width:width+m-1);
      
      # applying inverse dct
      redBlock = idct2(redBlock);
      blueBlock = idct2(blueBlock);
      greenBlock = idct2(greenBlock);
      
      # putting 8*8 block back in the image
      redChannel(heightIndex:heightIndex+7,widthIndex:widthIndex+7) = redBlock;
      blueChannel(heightIndex:heightIndex+7,widthIndex:widthIndex+7) = blueBlock;
      greenChannel(heightIndex:heightIndex+7,widthIndex:widthIndex+7) = greenBlock;      
      
      heightIndex = heightIndex +8;
      height = height + m;
    endwhile
    widthIndex = widthIndex +8;
    width = width + m;
  endwhile
  
  # casting channels to be displayed correctly
  redChannel = cast(redChannel,'uint8');
  blueChannel = cast(blueChannel,'uint8');
  greenChannel = cast(greenChannel,'uint8');
  testImage = cat(3 , redChannel , greenChannel , blueChannel);
  figure; imshow(testImage); title("M = ",m);
  
  # calculating PSNR for each m
  display("PSNR of");
  display(m);
  display(psnr(testImage,rgbImage));
endfor
