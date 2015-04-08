#import "ADTickerLabel.h"

#import <QuartzCore/QuartzCore.h>

@interface ADTickerCharacterLabel : UILabel

@property (nonatomic) NSArray *charactersArray;
@property (nonatomic) NSString *selectedCharacter;

@property (nonatomic) float changeTextAnimationDuration;
@property (nonatomic) ADTickerLabelScrollDirection scrollDirection;
@property (nonatomic) NSInteger selectedCharacterIndex;

@end

@implementation ADTickerCharacterLabel

- (id)initWithFrame:(CGRect)frame
{
   if (self = [super initWithFrame: frame])
   {
      self.clipsToBounds = YES;
      self.backgroundColor = [UIColor clearColor];
   }
   return self;
}

- (void)setCharactersArray:(NSArray *)characters
{
   _charactersArray = characters;
   self.text = [characters componentsJoinedByString: @"\n"];
}

- (CGFloat)positionYForCharacterAtIndex:(NSInteger)index
{
   CGFloat characterHeight = self.frame.size.height / [self.charactersArray count];
   CGFloat position = -index * characterHeight;
   return position;
}

- (void)moveToPosition:(CGFloat)positionY
              animated:(BOOL)animated
            completion:(void(^)(void))completion
{
   CGRect newFrame = self.frame;
   newFrame.origin.y = positionY;

   if (animated)
   {
      [UIView animateWithDuration: self.changeTextAnimationDuration
                       animations:
       ^{
          self.frame = newFrame;
       }
                       completion:
       ^(BOOL finished)
      {
          
          completion();
       }];
   }
   else
   {
      self.frame = newFrame;
      completion();
   }
}

- (void)selectCharacter:(NSString *)selectedCharacter
               animated:(BOOL)animated
{
   if (self.scrollDirection == ADTickerLabelScrollDirectionUp)
   {
      NSInteger selectedCharacterIndex = [selectedCharacter integerValue];
      
      if (![selectedCharacter isEqualToString: @"."])
      {
         selectedCharacterIndex++;
      }

      if (selectedCharacterIndex <= self.selectedCharacterIndex)
      {
         [self moveToPosition: [self positionYForCharacterAtIndex: selectedCharacterIndex]
                     animated: animated
                   completion:
          ^{
             self.selectedCharacter = selectedCharacter;
             self.selectedCharacterIndex = selectedCharacterIndex;
          }];
      }
      else if(selectedCharacterIndex > self.selectedCharacterIndex)
      {
         //We try to find the character in second part of array
         NSUInteger searchLocation = [self.charactersArray count] / 2;
         selectedCharacterIndex = [ self.charactersArray indexOfObject: selectedCharacter
                                                               inRange: NSMakeRange(searchLocation, [self.charactersArray count] - searchLocation)];

         [self moveToPosition: [self positionYForCharacterAtIndex: selectedCharacterIndex]
                     animated: animated
                   completion:
          ^{
             self.selectedCharacter = selectedCharacter;
             self.selectedCharacterIndex = [self.charactersArray indexOfObject: selectedCharacter];
             
             CGRect newFrame = self.frame;
             newFrame.origin.y = [self positionYForCharacterAtIndex: self.selectedCharacterIndex];
             self.frame = newFrame;
          }];
      }
   }
   else
   {
      NSInteger selectedCharacterIndex = [self.charactersArray count] - 1 - [selectedCharacter integerValue];

      if ([selectedCharacter isEqualToString: @"."])
      {
         selectedCharacterIndex--;
      }

      if (selectedCharacterIndex < self.selectedCharacterIndex)
      {
         [self moveToPosition: [self positionYForCharacterAtIndex: selectedCharacterIndex]
                     animated: animated
                   completion:
          ^{
             self.selectedCharacter = selectedCharacter;
             self.selectedCharacterIndex = selectedCharacterIndex;
          }];
      }
      else if(selectedCharacterIndex > self.selectedCharacterIndex){
         
         //We try to find the character in second part of array
         NSUInteger searchLocation = [self.charactersArray count] / 2;
         selectedCharacterIndex = [self.charactersArray indexOfObject: selectedCharacter
                                                              inRange: NSMakeRange(searchLocation, [self.charactersArray count] - searchLocation)];

         [self moveToPosition: [self positionYForCharacterAtIndex: selectedCharacterIndex]
                     animated: animated
                   completion:
          ^{
             self.selectedCharacter = selectedCharacter;
             self.selectedCharacterIndex = [self.charactersArray indexOfObject: selectedCharacter];
             
             CGRect newFrame = self.frame;
             newFrame.origin.y = [self positionYForCharacterAtIndex: self.selectedCharacterIndex];
             self.frame = newFrame;
          }];
      }
   }
}

@end

@interface ADTickerLabel ()

@property (nonatomic, readonly) NSArray *characterViewsArray;
@property (nonatomic) NSArray *charactersArray;
@property (nonatomic) CGFloat characterWidth;
@property (nonatomic) float changeTextAnimationDuration;

@property (nonatomic) UIView* charactersView;

@end

@implementation ADTickerLabel

- (void)initializeLabel
{
   self.charactersView = [[UIView alloc] initWithFrame: self.bounds];
   self.charactersView.clipsToBounds = YES;
   self.charactersView.backgroundColor = [UIColor clearColor];
   [self addSubview: self.charactersView];

   self.font = [UIFont systemFontOfSize: 12.];
   self.textColor = [UIColor blackColor];
   self.changeTextAnimationDuration = 1.f;
   self.scrollDirection = ADTickerLabelScrollDirectionUp;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder: aDecoder];
   if (self) {
      [self initializeLabel];
   }
   return self;
}

- (id)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame: frame];
   if (self) {
      [self initializeLabel];
   }
   return self;
}

- (NSArray*)characterViewsArray
{
   return self.charactersView.subviews;
}

- (void)insertNewCharacterLabel
{
   CGRect labelFrame = CGRectZero;
   labelFrame.origin = CGPointZero;
   labelFrame.size = CGSizeMake(self.characterWidth, self.font.lineHeight * [self.charactersArray count]);
   labelFrame.origin.y = (self.scrollDirection == ADTickerLabelScrollDirectionDown) ? -self.font.lineHeight * ([self.charactersArray count] - 1) : 0;

   ADTickerCharacterLabel *characterLabel = [[ADTickerCharacterLabel alloc] initWithFrame:labelFrame];
   characterLabel.font = self.font;
   characterLabel.textAlignment = NSTextAlignmentRight;
   characterLabel.backgroundColor = [UIColor clearColor];
   characterLabel.textColor = self.textColor;
   characterLabel.numberOfLines = 0;
   characterLabel.shadowColor = self.shadowColor;
   characterLabel.shadowOffset = self.shadowOffset;

   characterLabel.selectedCharacter = @"0";
   characterLabel.selectedCharacterIndex = [self.charactersArray count] - 1;
   characterLabel.charactersArray = self.charactersArray;
   characterLabel.scrollDirection = self.scrollDirection;
   characterLabel.changeTextAnimationDuration = self.changeTextAnimationDuration;

   [self.charactersView addSubview: characterLabel];
}

- (void)removeLastCharacterLabel
{
   ADTickerCharacterLabel *numericView = [self.characterViewsArray lastObject];
   [numericView removeFromSuperview];
}

#pragma mark Interface

+ (NSArray*)charactersArray
{
   return @[@".", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @".", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];
}

- (void)setScrollDirection:(ADTickerLabelScrollDirection)direction
{
   if (direction != _scrollDirection)
   {
      _scrollDirection = direction;
      
      NSArray* charactersArray = [[self class] charactersArray];
      if (direction == ADTickerLabelScrollDirectionDown)
      {
         charactersArray = [charactersArray reverseObjectEnumerator].allObjects;
      }
      self.charactersArray = charactersArray;

      [self.characterViewsArray enumerateObjectsUsingBlock:
       ^(ADTickerCharacterLabel* label, NSUInteger idx, BOOL *stop)
       {
          [label setScrollDirection: direction];
       }];
   }
}

- (void)setChangeTextAnimationDuration:(float)duration
{
   if (_changeTextAnimationDuration != duration)
   {
      _changeTextAnimationDuration = duration;

      [self.characterViewsArray enumerateObjectsUsingBlock:
       ^(ADTickerCharacterLabel *label, NSUInteger idx, BOOL *stop)
       {
          label.changeTextAnimationDuration = duration;
       }];
   }
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
   _shadowOffset = shadowOffset;
   [self.characterViewsArray enumerateObjectsUsingBlock:
    ^(UILabel *label, NSUInteger idx, BOOL *stop)
    {
       label.shadowOffset = shadowOffset;
    }];
}

- (void)setShadowColor:(UIColor *)shadowColor
{
   _shadowColor = shadowColor;
   [self.characterViewsArray enumerateObjectsUsingBlock:
    ^(UILabel *label, NSUInteger idx, BOOL *stop)
    {
       label.shadowColor = shadowColor;
    }];
}

- (void)setTextColor:(UIColor *)textColor
{
   if (![_textColor isEqual: textColor])
   {
      _textColor = textColor;
      [self.characterViewsArray enumerateObjectsUsingBlock:
       ^(UILabel *label, NSUInteger idx, BOOL *stop)
       {
          label.textColor = textColor;
       }];
   }
}

- (void)setFont:(UIFont *)font
{
   if (![_font isEqual: font])
   {
      _font = font;
      self.characterWidth = [@"8" sizeWithAttributes:@{NSFontAttributeName: font}].width;

      [self.characterViewsArray enumerateObjectsUsingBlock:
       ^(UILabel *label, NSUInteger idx, BOOL *stop)
      {
         label.font = self.font;
      }];

      [self setNeedsLayout];
      [self invalidateIntrinsicContentSize];
   }
}

- (void)setText:(NSString *)text
{
   [self setText:text animated:YES];
}

- (void)setText:(NSString *)text
       animated:(BOOL)animated
{
   if ([_text isEqualToString: text])
   {
      return;
   }

   NSInteger oldTextLength = [_text length];
   NSInteger newTextLength = [text length];

   if (newTextLength > oldTextLength)
   {
      NSInteger textLengthDelta = newTextLength - oldTextLength;
      for (NSInteger i = 0 ; i < textLengthDelta; ++i)
      {
         [self insertNewCharacterLabel];
      }
      [self invalidateIntrinsicContentSize];
   }
   else if (newTextLength < oldTextLength)
   {
      NSInteger textLengthDelta = oldTextLength - newTextLength;
      for (NSInteger i = 0 ; i < textLengthDelta; ++i)
      {
         [self removeLastCharacterLabel];
      }
      [self invalidateIntrinsicContentSize];
   }

   [self.characterViewsArray enumerateObjectsUsingBlock:
    ^(ADTickerCharacterLabel *label, NSUInteger idx, BOOL *stop)
    {
       [label selectCharacter: [text substringWithRange:NSMakeRange(idx, 1)]
                     animated: animated];
    }];

   _text = text;
}

- (void)setTextAlignment:(UITextAlignment)textAlignment
{
   _textAlignment = textAlignment;
   [self setNeedsLayout];
}

- (CGSize)intrinsicContentSize
{
   return CGSizeMake(self.characterWidth * self.text.length, UIViewNoIntrinsicMetric);
}

- (CGRect)characterViewFrameWithContentBounds:(CGRect)frame
{
   if (self.font.lineHeight > self.bounds.size.height)
   {
      frame.size.height = self.font.lineHeight;
      frame.origin.y = -(self.font.lineHeight - self.bounds.size.height) / 2.f;
   }
   
   CGFloat charactersWidth = [self.characterViewsArray count] * self.characterWidth;
   
   switch (self.textAlignment)
   {
      case NSTextAlignmentRight:
         frame.origin.x = self.frame.size.width - charactersWidth;
         break;
      case NSTextAlignmentCenter:
         frame.origin.x = (self.frame.size.width - charactersWidth) / 2;
         break;
      case NSTextAlignmentLeft:
      default:
         frame.origin.x = 0.0;
         break;
   }
   
   return frame;
}

- (void)layoutSubviews
{
   [super layoutSubviews];

   if ([self.characterViewsArray count] > 0)
   {
      self.charactersView.frame = [self characterViewFrameWithContentBounds: self.bounds];

      CGRect characterFrame = CGRectZero;
      for (UIView* characterView in self.characterViewsArray)
      {
         characterFrame.size.height = characterView.frame.size.height;
         characterFrame.origin.y = (self.scrollDirection == ADTickerLabelScrollDirectionDown) ? -self.font.lineHeight * ([self.charactersArray count] - 1) : 0;
         characterFrame.size.width = self.characterWidth;
         characterView.frame = characterFrame;

         characterFrame.origin.x += self.characterWidth;
      }
   }
}

@end
