trigger validateCaseComment on CaseComment (before insert, before update) {
   
    for (CaseComment comment: Trigger.new){        
        String commentText = comment.CommentBody.replace(' ', '');   
        commentText = commentText.replace('-', '');
        commentText = commentText.replace('\r\n', ' ');
        commentText = commentText.replace('\n', ' ');
        commentText = commentText.replace('\r', ' ');
        if(Pattern.matches('(.*[0-9]{16}.*)*', commentText)){
            comment.CommentBody.addError(Label.Case_ERR016);
        }          
    }
}