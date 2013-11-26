;;; Erick Nave
;;; Survey of Programming Languages
;;; Program Assignment 5
;;; Start 4-29-94
;;; Last Update 5-5-94

(defun ancestors (x &optional (fam family-data))
;;; ancestors finds the ancestors of x in fam.  It does so by searching the
;;;   association list using assoc for x. Then if the cadr of that is
;;;   another person, ancestors recursively calls itself using the cadr
;;;   for the new x.
   (cond
      ((null (cadr (assoc x fam))) (list x))
      (t (append (list x) (ancestors (cadr (assoc x fam)) fam)))))

(defun remove-parens (x)
;;; remove-parens combines all of the lists within the list x into one list
   (cond
      ((null x) nil)
      ((atom x) (list x))
      ((atom (car x)) (append (list (car x)) (remove-parens (cdr x))))
      (t (append (remove-parens (car x)) (remove-parens (cdr x))))))

(defun remove-z (x)
;;; remove-z removes all z's places into the list x from the mapcar of the 
;;;   lambda function in descendants.
   (cond 
     ((null x) nil)
     ((equal (car x) 'z) (remove-z (cdr x)))
     (t (cons (car x) (remove-z (cdr x))))))
 
(defun descendants (x &optional (fam family-data))
;;; descendants finds the descendants of x in fam by applying mapcar to a
;;;   lambda expression that says that if x is found in the cadr of that
;;;   component of the association list, then find the descendants of the
;;;   car of that component.
    (remove-parens (append (list x) (remove-z (mapcar 
      #'(lambda (y)
          (if (equal x (cadr y))
            (descendants (car y)) 'z)) fam)))))

(defun gengap (x y &optional (fam family-data) (gap 0))
;;; gengap finds the generation gap between x and y by incrementing
;;;   gap by 1 as x moves up the list until it either finds y or it
;;;   reaches the top without finding y in which case nil is returned
   (cond
      ((equalp x y) gap)
      ((null (cadr (assoc x fam))) nil)
      (t (setf gap (+ 1 gap))
         (gengap (cadr (assoc x fam)) y fam gap))))

(defun nca (x y &optional (fam family-data))
;;; nca finds the nearest common ancestor between x and y by moving x up the
;;;    list until there is a generation gap between x and y which means that
;;;    x is the nca.
   (cond
      ((null x) nil)
      ((gengap y x) x)
      (t (nca (cadr (assoc x fam)) y))))

(defun relation (x y &optional (gender nil) (fam family-data)
                 &aux name xgap ygap cous rem)
;;; relation determines how x is related to y through a series of decision
;;;    structures.
   (setf name (nca x y))
   (setf xgap (gengap x name))
   (setf ygap (gengap y name))
   (if (null gender) (setf gender (caddr (assoc x fam))))
   (cond
      ((or (null xgap) (null ygap)) (list 'no 'relation))
      ((and (equal xgap 0) (equal ygap 0)) (list 'same 'person))
      ((equal xgap 1)
          (cond
             ((equal ygap 0)
                 (if (equal gender 'm) 
                    (list 'son)
                    (list 'daughter)))
             ((equal ygap 1)
                 (if (equal gender 'm)
                    (list 'brother)
                    (list 'sister)))
             ((equal ygap 2)
                 (if (equal gender 'm)
                    (list 'uncle)
                    (list 'aunt)))
             ((equal ygap 3)
                 (if (equal gender 'm)
                    (list 'grand 'uncle)
                    (list 'grand 'aunt)))
             (t (append (list 'great) (relation x (cadr (assoc y fam)) 
                                                gender)))))
      ((equal ygap 1)
          (cond
             ((equal xgap 0)
                 (if (equal gender 'm)
                    (list 'father)
                    (list 'mother)))
             ((equal xgap 2)
                 (if (equal gender 'm)
                    (list 'nephew)
                    (list 'niece)))
             ((equal xgap 3)
                 (if (equal gender 'm)
                    (list 'grand 'nephew)
                    (list 'grand 'niece)))
             (t (append (list 'great) (relation (cadr (assoc x fam)) y
                                                  gender)))))
      ((equal xgap 0)
          (cond
             ((equal ygap 2)
                 (if (equal gender 'm)
                    (list 'grand 'father)
                    (list 'grand 'mother)))
              (t (append (list 'great) (relation x (cadr (assoc y fam))
                                                   gender)))))
      ((equal ygap 0)
         (cond
            ((equal xgap 2)
                (if (equal gender 'm)
                   (list 'grand 'son)
                   (list 'grand 'daughter)))
            (t (append (list 'great) (relation (cadr (assoc x fam)) y
                                                 gender)))))
      (t (if (< xgap ygap)
            (list (- xgap 1) 'cousin 'removed (- ygap xgap))
            (list (- ygap 1) 'cousin 'removed (- xgap ygap))))))



