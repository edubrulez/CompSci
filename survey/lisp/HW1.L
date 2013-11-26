(defun slope (pt1 pt2)
   (if (equal (car pt1) (car pt2))
        nil
        (/ (- (cadr pt1) (cadr pt2)) (- (car pt1) (car pt2)))))

(defun midpt (pt1 pt2)
   (list (/ (+ (car pt1) (car pt2)) 2)
         (/ (+ (cadr pt1) (cadr pt2)) 2)))

(defun multiple-member (x y)
   (if (member x (cdr (member x y)))
       T
       nil))
