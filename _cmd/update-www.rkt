#lang racket

(require odysseus)
(require odysseus/api/vk)
(require odysseus/api/csv)
(require tabtree)
(require tabtree/html)
(require (file "/home/denis/.private/APIs.rkt"))

(require "../_lib/globals.rkt")
(require "../_lib/functions.rkt")
(require "../_lib/page_snippets.rkt")

(define-namespace-anchor a)
(define ns (namespace-anchor->namespace a))

(define news_cards "")
(define page-id "")

(persistent h-galias-gid)
(persistent anapa-posts)
; (persistent dzau-posts)
; (persistent taganrog-posts)
(persistent shebekino-posts)

(set-access-token ($ access_token vk/postagg3_1))

(define anapa.tree "../knowledge/anapa.tree")
(define dzau.tree "../knowledge/dzau.tree")
(define taganrog.tree "../knowledge/taganrog.tree")
(define shebekino.tree "../knowledge/shebekino.tree")

(define anapa-items (get-entities anapa.tree))
(define dzau-items (get-entities dzau.tree))
(define taganrog-items (get-entities taganrog.tree))
(define shebekino-items (get-entities shebekino.tree))

(define PAGES (get-sitemap))

(define-catch (update-cache)
  (parameterize ((Name-id-hash (h-galias-gid)))
    (cache-posts
        #:source (list anapa.tree)
        #:write-to-cache (string-append CACHE_DIR "/anapa_posts.rktd")
        #:ignore-with-status #t
        #:ignore-sleepy #t
        #:read-depth 42)
    ; (cache-posts
    ;     #:source (list dzau.tree)
    ;     #:write-to-cache (string-append CACHE_DIR "/dzau_posts.rktd")
    ;     #:ignore-with-status #t
    ;     #:ignore-sleepy #t
    ;     #:read-depth 12)
    ; (cache-posts
    ;     #:source (list taganrog.tree)
    ;     #:write-to-cache (string-append CACHE_DIR "/taganrog_posts.rktd")
    ;     #:ignore-with-status #t
    ;     #:ignore-sleepy #t
    ;     #:read-depth 12)
    (cache-posts
        #:source (list shebekino.tree)
        #:write-to-cache (string-append CACHE_DIR "/shebekino_posts.rktd")
        #:ignore-with-status #t
        #:ignore-sleepy #t
        #:read-depth 24)
  #t))

(define-catch (update-page page_id #:note (note "") #:template (template-name #f) #:gen-ext (gen-ext "html"))
  (unless (empty-string? note) (--- (str "\n" note)))
  (set! page-id page_id)
  (let* ((page-id-string (string-downcase (->string page-id)))
        (template-name (or template-name page-id-string))
        (processed-template (process-html-template (format "../_templates/~a.t" template-name) #:tabtree-root "../knowledge" #:namespace ns)))
    (write-file (format "~a/~a.~a" SERVER_DIR page-id-string gen-ext) processed-template)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(--- (format "~a: Обновляем контент сайта" (timestamp)))

(update-cache)

(--- "Компилируем страницы сайта")

(set! news_cards (make-cards
                    (filter-posts
                        (anapa-posts)
                        #:entities anapa-items
                        #:within-days WITHIN_DAYS
                        #:min-symbols MIN_SYMBOLS)
                    #:entities anapa-items
                    #:max-brs MAX_BRS
                    ))
(update-page 'Anapa #:note "Объявления Анапы" #:template "news")
; (-s (copy-file "../www/anapa.html" (format "~a/anapa.html" SERVER-PATH)))

; (set! news_cards (make-cards
;                     (filter-posts
;                         (dzau-posts)
;                         #:entities dzau-items
;                         #:within-days WITHIN_DAYS
;                         #:min-symbols MIN_SYMBOLS)
;                     #:entities dzau-items
;                     #:max-brs MAX_BRS
;                     ))
; (update-page 'Dzau #:note "Объявления Владикавказа" #:template "news")
;
; (set! news_cards (make-cards
;                     (filter-posts
;                         (taganrog-posts)
;                         #:entities taganrog-items
;                         #:within-days WITHIN_DAYS
;                         #:min-symbols MIN_SYMBOLS)
;                     #:entities taganrog-items
;                     #:max-brs MAX_BRS
;                     ))
; (update-page 'Taganrog #:note "Объявления Таганрога" #:template "news")

(set! news_cards (make-cards
                    (filter-posts
                        (shebekino-posts)
                        #:entities shebekino-items
                        #:within-days WITHIN_DAYS
                        #:min-symbols MIN_SYMBOLS)
                    #:entities shebekino-items
                    #:max-brs MAX_BRS
                    ))
(update-page 'Shebekino #:note "Объявления Шебекино" #:template "news")
; (-s (copy-file "../www/shebekino.html" (format "~a/shebekino.html" SERVER-PATH)))

(--- (format "~a Конец компиляции~n~n" (timestamp)))

(get-url "http://losikovik.nasevere51.ru/updater.php")
